from __future__ import annotations

import asyncio
import logging
import platform
from typing import Dict, List

from .api import ApiClient
from .config import AgentConfig
from .discovery import DiscoveredCamera, discover_cameras
from .logging_setup import configure_logging
from .signaling import SignalingClient
from .system_metrics import cpu_temperature, local_ip, uptime_seconds
from .webrtc import WebRTCManager

logger = logging.getLogger(__name__)


class SamiAgent:
  def __init__(self, config: AgentConfig) -> None:
    self._config = config
    self._buffer_handler = configure_logging(
      config.log_path,
      config.log_max_bytes,
      config.log_backups,
    )
    self._api = ApiClient(config.api_base, config.tenant_id, config.device_id, config.device_key)
    self._webrtc = WebRTCManager(max_streams=config.max_streams)
    self._signaling = SignalingClient(
      url=config.signaling_url,
      tenant_id=config.tenant_id,
      device_id=config.device_id,
      device_key=config.device_key,
      metrics_cb=self._ws_metrics,
      start_stream_cb=self._handle_start_stream,
      stop_stream_cb=self._handle_stop_stream,
      webrtc_answer_cb=self._webrtc.handle_answer,
      webrtc_candidate_cb=self._webrtc.handle_remote_candidate,
      set_webrtc_sender=self._webrtc.set_sender,
      stop_all_cb=self._webrtc.stop_all,
      heartbeat_interval=config.heartbeat_seconds,
    )
    self._cameras: Dict[str, DiscoveredCamera] = {}
    self._shutdown = asyncio.Event()

  async def run(self) -> None:
    logger.info('starting agent for device %s', self._config.device_id)
    await self._register_device()
    await self._discover_and_publish()
    tasks = [
      asyncio.create_task(self._heartbeat_loop()),
      asyncio.create_task(self._discovery_loop()),
      asyncio.create_task(self._log_forwarder_loop()),
      asyncio.create_task(self._signaling.run()),
    ]
    try:
      await self._shutdown.wait()
    finally:
      for task in tasks:
        task.cancel()
      await asyncio.gather(*tasks, return_exceptions=True)
      await self._signaling.close()
      await self._webrtc.stop_all()
      await self._api.close()
      logger.info('agent stopped')

  async def stop(self) -> None:
    self._shutdown.set()

  async def _register_device(self) -> None:
    payload = {
      'tenantId': self._config.tenant_id,
      'deviceId': self._config.device_id,
      'siteId': self._config.site_id,
      'ipLocal': local_ip(),
      'version': platform.platform(),
    }
    async with self._api:
      await self._api.register_device(payload)

  async def _discover_and_publish(self) -> None:
    cameras = await discover_cameras(self._config.discover)
    self._cameras = {camera.camera_id: camera for camera in cameras}
    async with self._api:
      await self._api.publish_cameras(
        [
          {
            'cameraId': camera.camera_id,
            'label': camera.label,
            'rtspUrl': camera.rtsp_url,
            'metadata': camera.metadata,
          }
          for camera in cameras
        ]
      )

  async def _heartbeat_loop(self) -> None:
    interval = max(10, self._config.heartbeat_seconds)
    while True:
      payload = {
        'deviceId': self._config.device_id,
        'ipLocal': local_ip(),
        'tempC': cpu_temperature(),
        'uptimeSec': uptime_seconds(),
      }
      try:
        async with self._api:
          await self._api.post_heartbeat(payload)
      except Exception as exc:  # noqa: BLE001
        logger.warning('heartbeat error: %s', exc)
      await asyncio.sleep(interval)

  async def _discovery_loop(self) -> None:
    while True:
      try:
        await self._discover_and_publish()
      except Exception as exc:  # noqa: BLE001
        logger.warning('discovery failed: %s', exc)
      await asyncio.sleep(600)

  async def _log_forwarder_loop(self) -> None:
    while True:
      await asyncio.sleep(120)
      logs = self._drain_logs()
      try:
        async with self._api:
          await self._api.upload_logs(logs)
      except Exception as exc:  # noqa: BLE001
        logger.debug('upload logs failed: %s', exc)

  def _drain_logs(self) -> List[str]:
    buffer = list(self._buffer_handler.buffer)
    self._buffer_handler.buffer.clear()
    return buffer

  def _ws_metrics(self) -> dict[str, object]:
    return {
      'ipLocal': local_ip(),
      'tempC': cpu_temperature(),
      'uptimeSec': uptime_seconds(),
    }

  async def _handle_start_stream(self, camera_id: str) -> bool:
    camera = self._cameras.get(camera_id)
    if not camera:
      logger.warning('start_stream for unknown camera %s', camera_id)
      return False
    try:
      await self._webrtc.start_stream(camera_id, camera.rtsp_url)
      return True
    except Exception as exc:  # noqa: BLE001
      logger.error('failed to start stream %s: %s', camera_id, exc)
      return False

  async def _handle_stop_stream(self, camera_id: str) -> None:
    await self._webrtc.stop_stream(camera_id)
