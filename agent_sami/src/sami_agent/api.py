from __future__ import annotations

import asyncio
import logging
from typing import Any, Iterable

import aiohttp

logger = logging.getLogger(__name__)

MAX_RETRIES = 5
INITIAL_BACKOFF = 1.0
BACKOFF_MULTIPLIER = 2.0


class ApiClient:
  def __init__(self, base_url: str, tenant_id: str, device_id: str, device_key: str) -> None:
    self._base_url = base_url.rstrip('/')
    self._tenant_id = tenant_id
    self._device_id = device_id
    self._device_key = device_key
    self._session: aiohttp.ClientSession | None = None

  async def __aenter__(self) -> 'ApiClient':
    await self._ensure_session()
    return self

  async def __aexit__(self, *_exc: object) -> None:
    if self._session and not self._session.closed:
      await self._session.close()

  async def close(self) -> None:
    if self._session and not self._session.closed:
      await self._session.close()

  async def register_device(self, payload: dict[str, Any]) -> None:
    await self._post('/devices/register', payload)

  async def post_heartbeat(self, payload: dict[str, Any]) -> None:
    await self._post('/devices/heartbeat', payload)

  async def publish_cameras(self, cameras: Iterable[dict[str, Any]]) -> None:
    await self._post(f'/devices/{self._device_id}/cameras', {'cameras': list(cameras)})

  async def upload_logs(self, logs: Iterable[str]) -> None:
    entries = list(logs)
    if not entries:
      return
    await self._post('/devices/logs', {'entries': entries})

  async def _post(self, path: str, payload: dict[str, Any]) -> None:
    await self._ensure_session()
    url = f'{self._base_url}{path}'
    assert self._session is not None
    backoff = INITIAL_BACKOFF
    for attempt in range(1, MAX_RETRIES + 1):
      try:
        async with self._session.post(url, json=payload, timeout=aiohttp.ClientTimeout(total=20)) as resp:
          if resp.status < 400:
            return
          text = await resp.text()
          raise ApiError(resp.status, text)
      except Exception as exc:  # noqa: BLE001
        if attempt == MAX_RETRIES:
          logger.error('api request %s failed after %s attempts: %s', url, attempt, exc)
          raise
        logger.warning('api request %s failed (%s), retrying in %.1fs', url, exc, backoff)
        await asyncio.sleep(backoff)
        backoff *= BACKOFF_MULTIPLIER

  async def _ensure_session(self) -> None:
    if self._session is None or self._session.closed:
      headers = {
        'X-Tenant-Id': self._tenant_id,
        'X-Device-Id': self._device_id,
        'X-Device-Key': self._device_key,
      }
      self._session = aiohttp.ClientSession(headers=headers)


class ApiError(RuntimeError):
  def __init__(self, status: int, message: str) -> None:
    super().__init__(f'{status}: {message}')
    self.status = status
    self.message = message
