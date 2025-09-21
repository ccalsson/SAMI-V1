#!/usr/bin/env python3
from __future__ import annotations

import argparse
import asyncio
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'src'))

from sami_agent.config import load_config
from sami_agent.discovery import discover_cameras


async def main() -> None:
  parser = argparse.ArgumentParser(description='Dry-run discovery without backend calls')
  parser.add_argument('--config', default='/etc/sami/config.yaml')
  args = parser.parse_args()

  config = load_config(args.config)
  cameras = await discover_cameras(config.discover)
  for camera in cameras:
    payload = {
      'cameraId': camera.camera_id,
      'label': camera.label,
      'rtspUrl': camera.rtsp_url,
      'metadata': camera.metadata,
    }
    print(json.dumps(payload, ensure_ascii=False))


if __name__ == '__main__':
  asyncio.run(main())
