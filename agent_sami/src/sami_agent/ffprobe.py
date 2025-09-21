from __future__ import annotations

import json
import subprocess
from typing import Any

FALLBACK_PATHS = ('/usr/bin/ffprobe', '/usr/local/bin/ffprobe', 'ffprobe')


class ProbeResult:
  def __init__(self, playable: bool, metadata: dict[str, Any] | None = None) -> None:
    self.playable = playable
    self.metadata = metadata or {}


def run_ffprobe(url: str, timeout: int = 10) -> ProbeResult:
  for binary in FALLBACK_PATHS:
    try:
      completed = subprocess.run(
        [binary, '-v', 'quiet', '-print_format', 'json', '-show_streams', url],
        capture_output=True,
        check=True,
        text=True,
        timeout=timeout,
      )
      data = json.loads(completed.stdout or '{}')
      streams = data.get('streams', [])
      playable = any(stream.get('codec_type') == 'video' for stream in streams)
      metadata = {
        'streams': [
          {
            'codec': stream.get('codec_name'),
            'width': stream.get('width'),
            'height': stream.get('height'),
            'fps': stream.get('avg_frame_rate'),
          }
          for stream in streams
          if stream.get('codec_type') == 'video'
        ]
      }
      return ProbeResult(playable=playable, metadata=metadata)
    except FileNotFoundError:
      continue
    except subprocess.SubprocessError:
      return ProbeResult(playable=False)
  return ProbeResult(playable=False)


def is_playable(url: str) -> bool:
  return run_ffprobe(url).playable
