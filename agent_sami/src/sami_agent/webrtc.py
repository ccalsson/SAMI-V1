from __future__ import annotations

import asyncio
import logging
from dataclasses import dataclass
from typing import Awaitable, Callable, Dict

from aiortc import RTCPeerConnection, RTCIceCandidate, RTCSessionDescription
from aiortc.contrib.media import MediaPlayer

logger = logging.getLogger(__name__)

SendCallback = Callable[[dict[str, object]], Awaitable[None]]


@dataclass
class StreamContext:
  pc: RTCPeerConnection
  player: MediaPlayer
  task: asyncio.Task | None


class WebRTCManager:
  def __init__(self, max_streams: int) -> None:
    self._max_streams = max_streams
    self._streams: Dict[str, StreamContext] = {}
    self._send: SendCallback | None = None
    self._lock = asyncio.Lock()

  def set_sender(self, send: SendCallback | None) -> None:
    self._send = send

  async def start_stream(self, camera_id: str, rtsp_url: str) -> None:
    async with self._lock:
      if camera_id in self._streams:
        return
      if len(self._streams) >= self._max_streams:
        raise RuntimeError('max streams exceeded')
      player = MediaPlayer(rtsp_url, format='rtsp', options={'rtsp_transport': 'tcp'})
      pc = RTCPeerConnection()

      @pc.on('icecandidate')
      async def on_icecandidate(candidate) -> None:
        if candidate and self._send:
          await self._send(
            {
              'type': 'ice_candidate',
              'cameraId': camera_id,
              'candidate': candidate.to_sdp(),
              'sdpMid': candidate.sdp_mid,
              'sdpMLineIndex': candidate.sdp_mline_index,
            }
          )

      @pc.on('connectionstatechange')
      async def on_state_change() -> None:
        if pc.connectionState in {'failed', 'disconnected', 'closed'}:
          await self.stop_stream(camera_id)

      if player.audio:
        pc.addTrack(player.audio)
      if player.video:
        pc.addTrack(player.video)

      offer = await pc.createOffer()
      await pc.setLocalDescription(offer)
      if not self._send:
        raise RuntimeError('signaling not available')
      await self._send(
        {
          'type': 'sdp_offer',
          'cameraId': camera_id,
          'sdp': pc.localDescription.sdp,
          'mid': 'video',
        }
      )
      context = StreamContext(pc=pc, player=player, task=None)
      self._streams[camera_id] = context

  async def handle_answer(self, camera_id: str, sdp: str) -> None:
    context = self._streams.get(camera_id)
    if not context:
      return
    await context.pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'))

  async def handle_remote_candidate(
    self,
    camera_id: str,
    candidate: str,
    sdp_mid: str | None,
    sdp_mline_index: int | None,
  ) -> None:
    context = self._streams.get(camera_id)
    if not context:
      return
    if not candidate:
      return
    ice = RTCIceCandidate(candidate=candidate, sdpMid=sdp_mid, sdpMLineIndex=sdp_mline_index)
    await context.pc.addIceCandidate(ice)

  async def stop_stream(self, camera_id: str) -> None:
    async with self._lock:
      context = self._streams.pop(camera_id, None)
    if not context:
      return
    try:
      await context.player.stop()
    except Exception:  # noqa: BLE001
      pass
    await context.pc.close()

  async def stop_all(self) -> None:
    tasks = [self.stop_stream(cid) for cid in list(self._streams.keys())]
    await asyncio.gather(*tasks, return_exceptions=True)
