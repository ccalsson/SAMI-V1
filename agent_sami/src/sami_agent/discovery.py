from __future__ import annotations

import asyncio
import ipaddress
import logging
import socket
import uuid
from dataclasses import dataclass
from typing import Iterable, List
from urllib.parse import urlparse, urlunparse

from .config import DiscoverConfig
from .ffprobe import run_ffprobe

logger = logging.getLogger(__name__)

WS_DISCOVERY_MULTICAST = ('239.255.255.250', 3702)
PROBE_MESSAGE = (
  '<?xml version="1.0" encoding="UTF-8"?>'
  '<e:Envelope xmlns:e="http://www.w3.org/2003/05/soap-envelope" '
  'xmlns:w="http://schemas.xmlsoap.org/ws/2004/08/addressing" '
  'xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" '
  'xmlns:dn="http://www.onvif.org/ver10/network/wsdl">'
  '<e:Header>'
  '<w:MessageID>uuid:{uuid}</w:MessageID>'
  '<w:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To>'
  '<w:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</w:Action>'
  '</e:Header>'
  '<e:Body>'
  '<d:Probe>'
  '<d:Types>dn:NetworkVideoTransmitter</d:Types>'
  '</d:Probe>'
  '</e:Body>'
  '</e:Envelope>'
)

COMMON_RTSP_PATHS = (
  '',
  '/Streaming/Channels/101',
  '/Streaming/Channels/102',
  '/Streaming/Channels/1',
  '/Streaming/channels/101',
  '/h264',
  '/live',
  '/live/ch00_0',
  '/cam/realmonitor?channel=1&subtype=0',
)


@dataclass
class DiscoveredCamera:
  camera_id: str
  label: str
  rtsp_url: str
  metadata: dict[str, str]


async def discover_cameras(config: DiscoverConfig, timeout: int = 5) -> list[DiscoveredCamera]:
  results: list[DiscoveredCamera] = []
  if config.onvif:
    results.extend(await _discover_onvif(timeout=timeout))
  if config.rtsp_scan:
    results.extend(await _scan_rtsp_ranges(config.rtsp_scan))
  return _deduplicate(results)


async def _discover_onvif(timeout: int) -> list[DiscoveredCamera]:
  message = PROBE_MESSAGE.format(uuid=uuid.uuid4())
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
  sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
  sock.settimeout(timeout)
  try:
    sock.sendto(message.encode('utf-8'), WS_DISCOVERY_MULTICAST)
    endpoints: set[str] = set()
    while True:
      try:
        data, addr = sock.recvfrom(8192)
      except socket.timeout:
        break
      if not data:
        continue
      xaddrs = _extract_xaddrs(data.decode('utf-8', errors='ignore'))
      endpoints.update(xaddrs)
    cameras: list[DiscoveredCamera] = []
    for endpoint in endpoints:
      camera = await asyncio.get_running_loop().run_in_executor(None, _probe_onvif, endpoint)
      if camera:
        cameras.append(camera)
    return cameras
  finally:
    sock.close()


def _extract_xaddrs(xml_text: str) -> List[str]:
  xaddrs: list[str] = []
  marker = 'XAddrs>'
  start = 0
  while True:
    idx = xml_text.find(marker, start)
    if idx == -1:
      break
    end = xml_text.find('<', idx + len(marker))
    if end == -1:
      break
    segment = xml_text[idx + len(marker):end].strip()
    xaddrs.extend(segment.split())
    start = end
  return xaddrs


def _probe_onvif(endpoint: str) -> DiscoveredCamera | None:
  try:
    from onvif import ONVIFCamera  # type: ignore
    parsed = urlparse(endpoint)
    host = parsed.hostname or ''
    if not host:
      return None
    port = parsed.port or 80
    camera = ONVIFCamera(host, port)
    media = camera.create_media_service()
    profiles = media.GetProfiles()
    if not profiles:
      return None
    stream_uri = media.GetStreamUri(
      {
        'StreamSetup': {
          'Stream': 'RTP-Unicast',
          'Transport': {'Protocol': 'RTSP'},
        },
        'ProfileToken': profiles[0].token,
      }
    )
    rtsp_url = stream_uri.Uri
    probe = run_ffprobe(rtsp_url)
    if not probe.playable:
      return None
    device_info = camera.devicemgmt.GetDeviceInformation()
    camera_id = f'onvif_{host.replace(".", "_")}'
    metadata = {
      'manufacturer': getattr(device_info, 'Manufacturer', ''),
      'model': getattr(device_info, 'Model', ''),
      'firmware': getattr(device_info, 'FirmwareVersion', ''),
    }
    return DiscoveredCamera(
      camera_id=camera_id,
      label=f'ONVIF {metadata.get("model") or host}',
      rtsp_url=rtsp_url,
      metadata=metadata,
    )
  except Exception as exc:  # noqa: BLE001
    logger.debug('onvif probe failed for %s: %s', endpoint, exc)
    return None


async def _scan_rtsp_ranges(entries: Iterable[str]) -> list[DiscoveredCamera]:
  sem = asyncio.Semaphore(8)
  tasks = []
  for entry in entries:
    for candidate in _expand_rtsp(entry):
      tasks.append(_probe_rtsp(candidate, sem))
  cameras = [res for res in await asyncio.gather(*tasks) if res]
  return cameras


async def _probe_rtsp(url: str, sem: asyncio.Semaphore) -> DiscoveredCamera | None:
  async with sem:
    probe = await asyncio.get_running_loop().run_in_executor(None, run_ffprobe, url)
    if not probe.playable:
      return None
    host = urlparse(url).hostname or 'camera'
    camera_id = f'rtsp_{host.replace(".", "_")}_{uuid.uuid4().hex[:6]}'
    metadata = {'streams': probe.metadata.get('streams', [])}
    return DiscoveredCamera(camera_id=camera_id, label=f'RTSP {host}', rtsp_url=url, metadata=metadata)


def _expand_rtsp(entry: str) -> Iterable[str]:
  parsed = urlparse(entry)
  if not parsed.scheme.startswith('rtsp'):
    return []
  host = parsed.hostname
  if not host:
    return []
  mask = None
  path = parsed.path or ''
  if path.startswith('/') and path[1:].isdigit():
    mask = int(path[1:])
    base_path = ''
  else:
    base_path = path
  port = parsed.port or 554
  try:
    if mask is not None:
      network = ipaddress.ip_network(f'{host}/{mask}', strict=False)
      hosts = list(network.hosts())
    else:
      hosts = [ipaddress.ip_address(host)]
  except ValueError:
    return []
  urls: list[str] = []
  credential = ''
  if parsed.username:
    credential = parsed.username
    if parsed.password:
      credential += f':{parsed.password}'
    credential += '@'
  for ip_addr in hosts:
    host_str = str(ip_addr)
    netloc = f'{credential}{host_str}:{port}'
    for suffix in COMMON_RTSP_PATHS:
      final_path = base_path or suffix
      if not final_path.startswith('/') and final_path:
        final_path = '/' + final_path
      url = urlunparse((parsed.scheme, netloc, final_path, '', '', ''))
      urls.append(url)
  return urls


def _deduplicate(cameras: list[DiscoveredCamera]) -> list[DiscoveredCamera]:
  seen: set[str] = set()
  result: list[DiscoveredCamera] = []
  for camera in cameras:
    if camera.rtsp_url in seen:
      continue
    seen.add(camera.rtsp_url)
    result.append(camera)
  return result
