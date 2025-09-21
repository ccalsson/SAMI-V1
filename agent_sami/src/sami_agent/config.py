from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


@dataclass(frozen=True)
class DiscoverConfig:
  onvif: bool
  rtsp_scan: list[str]


@dataclass(frozen=True)
class AgentConfig:
  tenant_id: str
  device_id: str
  device_key: str
  signaling_url: str
  api_base: str
  site_id: str
  heartbeat_seconds: int
  discover: DiscoverConfig
  log_path: Path
  log_max_bytes: int
  log_backups: int
  max_streams: int


def load_config(path: str | Path) -> AgentConfig:
  raw = _read_yaml(path)
  discover = raw.get('discover', {})
  return AgentConfig(
    tenant_id=_require(raw, 'tenantId'),
    device_id=_require(raw, 'deviceId'),
    device_key=_require(raw, 'deviceKey'),
    signaling_url=_require(raw, 'signalingUrl'),
    api_base=_require(raw, 'apiBase').rstrip('/'),
    site_id=_require(raw, 'siteId'),
    heartbeat_seconds=int(raw.get('heartbeatSeconds', 30)),
    discover=DiscoverConfig(
      onvif=bool(discover.get('onvif', True)),
      rtsp_scan=[str(item) for item in discover.get('rtspScan', [])],
    ),
    log_path=Path(raw.get('logPath', '/var/log/sami-agent/agent.log')),
    log_max_bytes=int(raw.get('logMaxBytes', 10_000_000)),
    log_backups=int(raw.get('logBackups', 5)),
    max_streams=int(raw.get('maxStreams', 4)),
  )


def _read_yaml(path: str | Path) -> dict[str, Any]:
  with open(Path(path), 'r', encoding='utf-8') as handle:
    data = yaml.safe_load(handle)
  if not isinstance(data, dict):
    raise ValueError('config must contain a mapping')
  return data


def _require(mapping: dict[str, Any], key: str) -> str:
  if key not in mapping or mapping[key] is None:
    raise KeyError(f'missing required config key: {key}')
  return str(mapping[key])
