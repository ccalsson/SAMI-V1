from __future__ import annotations

import logging
from collections import deque
from logging.handlers import RotatingFileHandler
from pathlib import Path
from typing import Deque


class BufferHandler(logging.Handler):
  def __init__(self, capacity: int) -> None:
    super().__init__()
    self.buffer: Deque[str] = deque(maxlen=capacity)

  def emit(self, record: logging.LogRecord) -> None:  # noqa: D401
    try:
      msg = self.format(record)
      self.buffer.append(msg)
    except Exception:  # noqa: BLE001
      pass


def configure_logging(path: Path, max_bytes: int, backups: int) -> BufferHandler:
  path.parent.mkdir(parents=True, exist_ok=True)
  file_handler = RotatingFileHandler(path, maxBytes=max_bytes, backupCount=backups)
  formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s - %(message)s')
  file_handler.setFormatter(formatter)

  buffer_handler = BufferHandler(capacity=200)
  buffer_handler.setFormatter(formatter)

  root = logging.getLogger()
  root.setLevel(logging.INFO)
  root.addHandler(file_handler)
  root.addHandler(buffer_handler)
  logging.getLogger('aiortc').setLevel(logging.WARNING)
  logging.getLogger('aiohttp').setLevel(logging.WARNING)
  return buffer_handler
