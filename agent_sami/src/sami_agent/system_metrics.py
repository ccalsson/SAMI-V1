from __future__ import annotations

import socket
from datetime import datetime

import netifaces
import psutil


def local_ip() -> str:
  for interface in netifaces.interfaces():
    addresses = netifaces.ifaddresses(interface)
    inet = addresses.get(netifaces.AF_INET)
    if not inet:
      continue
    for entry in inet:
      addr = entry.get('addr')
      if addr and not addr.startswith('127.'):
        return addr
  return socket.gethostbyname(socket.gethostname())


def cpu_temperature() -> float:
  temps = psutil.sensors_temperatures()
  if not temps:
    return 0.0
  for entries in temps.values():
    for entry in entries:
      if entry.current:
        return float(entry.current)
  return 0.0


def uptime_seconds() -> int:
  boot = datetime.fromtimestamp(psutil.boot_time())
  return int((datetime.utcnow() - boot).total_seconds())
