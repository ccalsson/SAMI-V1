from __future__ import annotations

import asyncio
import contextlib
import json
import logging
from typing import Awaitable, Callable, Dict

import websockets
from websockets.client import WebSocketClientProtocol

logger = logging.getLogger(__name__)


class SignalingClient:
  def __init__(
    self,
    url: str,
    tenant_id: str,
    device_id: str,
    device_key: str,
    metrics_cb: Callable[[], dict[str, object]],
    start_stream_cb: Callable[[str], Awaitable[bool]],
    stop_stream_cb: Callable[[str], Awaitable[None]],
    webrtc_answer_cb: Callable[[str, str], Awaitable[None]],
    webrtc_candidate_cb: Callable[[str, str, str | None, int | None], Awaitable[None]],
    set_webrtc_sender: Callable[[Callable[[dict[str, object]], Awaitable[None]] | None], None],
    stop_all_cb: Callable[[], Awaitable[None]],
    heartbeat_interval: int,
    max_backoff: int = 60,
  ) -> None:
    self._url = url
    self._tenant_id = tenant_id
    self._device_id = device_id
    self._device_key = device_key
    self._metrics_cb = metrics_cb
    self._start_stream_cb = start_stream_cb
    self._stop_stream_cb = stop_stream_cb
    self._webrtc_answer_cb = webrtc_answer_cb
    self._webrtc_candidate_cb = webrtc_candidate_cb
    self._set_webrtc_sender = set_webrtc_sender
    self._stop_all_cb = stop_all_cb
    self._heartbeat_interval = heartbeat_interval
    self._max_backoff = max_backoff
    self._send_lock = asyncio.Lock()
    self._ws: WebSocketClientProtocol | None = None
    self._running = True

  async def run(self) -> None:
    backoff = 1
    while self._running:
      try:
        await self._connect()
        backoff = 1
      except asyncio.CancelledError:
        raise
      except Exception as exc:  # noqa: BLE001
        logger.warning('signaling connection failed: %s', exc)
        await asyncio.sleep(backoff)
        backoff = min(backoff * 2, self._max_backoff)

  async def close(self) -> None:
    self._running = False
    if self._ws:
      await self._ws.close()

  async def send(self, payload: dict[str, object]) -> None:
    async with self._send_lock:
      if not self._ws or self._ws.closed:
        raise ConnectionError('signaling channel unavailable')
      await self._ws.send(json.dumps(payload))

  async def _connect(self) -> None:
    headers = {
      'X-Tenant-Id': self._tenant_id,
      'X-Device-Id': self._device_id,
      'X-Device-Key': self._device_key,
    }
    async with websockets.connect(
      self._url,
      extra_headers=headers,
      subprotocols=['sami-v1'],
      ping_interval=20,
      ping_timeout=20,
    ) as ws:
      self._ws = ws
      self._set_webrtc_sender(self.send)
      await self._send_register()
      heartbeat_task = asyncio.create_task(self._heartbeat_loop())
      try:
        async for raw in ws:
          try:
            message = json.loads(raw)
          except json.JSONDecodeError:
            logger.debug('ignoring invalid json: %s', raw)
            continue
          await self._handle_message(message)
      finally:
        heartbeat_task.cancel()
        with contextlib.suppress(asyncio.CancelledError):
          await heartbeat_task
        with contextlib.suppress(Exception):
          await self._stop_all_cb()
        self._set_webrtc_sender(None)
        self._ws = None

  async def _send_register(self) -> None:
    payload = {
      'type': 'register',
      'tenantId': self._tenant_id,
      'deviceId': self._device_id,
      'capabilities': {'webrtc': True, 'h264': True},
    }
    await self.send(payload)

  async def _heartbeat_loop(self) -> None:
    while True:
      await asyncio.sleep(self._heartbeat_interval)
      metrics = self._metrics_cb()
      metrics.update({'type': 'heartbeat', 'deviceId': self._device_id})
      try:
        await self.send(metrics)
      except Exception as exc:  # noqa: BLE001
        logger.debug('heartbeat send failed: %s', exc)
        raise

  async def _handle_message(self, message: Dict[str, object]) -> None:
    msg_type = message.get('type')
    if msg_type == 'start_stream':
      camera_id = str(message.get('cameraId', ''))
      if camera_id:
        await self._start_stream_cb(camera_id)
    elif msg_type == 'stop_stream':
      camera_id = str(message.get('cameraId', ''))
      if camera_id:
        await self._stop_stream_cb(camera_id)
    elif msg_type == 'sdp_answer':
      await self._webrtc_answer_cb(
        str(message.get('cameraId', '')),
        str(message.get('sdp', '')),
      )
    elif msg_type == 'ice_candidate':
      camera_id = str(message.get('cameraId', ''))
      candidate = message.get('candidate')
      if not camera_id or not candidate:
        return
      sdp_mid = message.get('sdpMid')
      mid = str(sdp_mid) if sdp_mid is not None else None
      sdp_mline = message.get('sdpMLineIndex')
      try:
        mid_index = int(sdp_mline) if sdp_mline is not None else None
      except (TypeError, ValueError):
        mid_index = None
      await self._webrtc_candidate_cb(camera_id, str(candidate), mid, mid_index)
    else:
      logger.debug('unknown signaling message: %s', message)
