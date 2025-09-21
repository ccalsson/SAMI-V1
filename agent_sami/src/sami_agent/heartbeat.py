from __future__ import annotations

import asyncio
import logging
import socket
from typing import Callable

import psutil

logger = logging.getLogger('sami_agent.heartbeat')


async def heartbeat_loop(
  interval: int,
  submit: Callable[[dict[str, object]], asyncio.Future | asyncio.Task | object],
) -> None:
  while True:
    payload = {
      'ipLocal': _current_ip(),
      'status': 'online',
      'temperature': _cpu_temperature(),
      'cpuPercent': psutil.cpu_percent(interval=None),
      'memoryPercent': psutil.virtual_memory().percent,
    }
    try:
      maybe_awaitable = submit(payload)
      if asyncio.iscoroutine(maybe_awaitable) or isinstance(maybe_awaitable, asyncio.Future):
        await maybe_awaitable
    except Exception as exc:  # noqa: BLE001
      logger.warning('heartbeat failed: %s', exc)
    await asyncio.sleep(interval)


def _current_ip() -> str:
  try:
    hostname = socket.gethostname()
    return socket.gethostbyname(hostname)
  except Exception:
    return '0.0.0.0'


def _cpu_temperature() -> float:
  try:
    temps = psutil.sensors_temperatures()
    if not temps:
      return 0.0
    for entries in temps.values():
      for entry in entries:
        if entry.current:
          return float(entry.current)
  except Exception:
    pass
  return 0.0
