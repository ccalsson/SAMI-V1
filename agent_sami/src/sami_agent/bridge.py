from __future__ import annotations

import asyncio
import json
import logging
from typing import Dict

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaPlayer

logger = logging.getLogger('sami_agent.bridge')


class StreamBridge:
  def __init__(self, signaling_url: str, tenant_id: str, device_id: str, device_key: str) -> None:
    self._signaling_url = signaling_url
    self._tenant_id = tenant_id
    self._device_id = device_id
    self._device_key = device_key
    self._players: Dict[str, MediaPlayer] = {}
    self._peers: Dict[str, RTCPeerConnection] = {}
    self._lock = asyncio.Lock()

  async def start_stream(self, camera_id: str, rtsp_url: str) -> None:
    async with self._lock:
      if camera_id in self._peers:
        return
      player = MediaPlayer(rtsp_url, format='rtsp', options={'rtsp_transport': 'tcp'})
      pc = RTCPeerConnection()
      for track in player.audio:
        pc.addTrack(track)
      for track in player.video:
        pc.addTrack(track)
      self._players[camera_id] = player
      self._peers[camera_id] = pc
      asyncio.create_task(self._negotiate(camera_id, pc))

  async def stop_stream(self, camera_id: str) -> None:
    async with self._lock:
      player = self._players.pop(camera_id, None)
      if player:
        await player.stop()
      pc = self._peers.pop(camera_id, None)
      if pc:
        await pc.close()

  async def shutdown(self) -> None:
    async with self._lock:
      ids = list(self._peers.keys())
    await asyncio.gather(*(self.stop_stream(cid) for cid in ids), return_exceptions=True)

  async def _negotiate(self, camera_id: str, pc: RTCPeerConnection) -> None:
    try:
      offer = await pc.createOffer()
      await pc.setLocalDescription(offer)
      payload = {
        'tenantId': self._tenant_id,
        'deviceId': self._device_id,
        'deviceKey': self._device_key,
        'cameraId': camera_id,
        'sdp': pc.localDescription.sdp,
        'type': pc.localDescription.type,
      }
      async with aiohttp.ClientSession() as session:
        async with session.ws_connect(self._signaling_url) as ws:
          await ws.send_str(json.dumps({'action': 'offer', 'data': payload}))
          async for msg in ws:
            if msg.type == aiohttp.WSMsgType.TEXT:
              data = json.loads(msg.data)
              if data.get('action') == 'answer' and data.get('cameraId') == camera_id:
                desc = data['data']
                await pc.setRemoteDescription(
                  RTCSessionDescription(desc['sdp'], desc['type'])
                )
                break
            if msg.type == aiohttp.WSMsgType.ERROR:
              raise RuntimeError('signaling error')
    except Exception as exc:  # noqa: BLE001
      logger.error('negotiation failed for %s: %s', camera_id, exc)
      await self.stop_stream(camera_id)
