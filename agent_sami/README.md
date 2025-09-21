# SAMI Edge Agent

Agente Python para Raspberry Pi o mini PC que registra el dispositivo, descubre cámaras ONVIF/RTSP y publica streams via WebRTC.

## Requisitos

- Python 3.11+
- ffmpeg/ffprobe instalados en el sistema
- Dependencias del sistema para `aiortc` (libffi, libopus, libvpx)

Instalar dependencias Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Configuración

Archivo `/etc/sami/config.yaml`:

```yaml
tenantId: tenant_demo
deviceId: device_pi_01
deviceKey: secret-key
siteId: site-123
signalingUrl: wss://signaling.sami.dev/ws
apiBase: https://api.sami.dev
heartbeatSeconds: 20
discover:
  onvif: true
  rtspScan:
    - "rtsp://user:pass@192.168.1.0/24"
logPath: /var/log/sami-agent/agent.log
logMaxBytes: 10000000
logBackups: 5
maxStreams: 4
```

## Ejecución manual

```bash
python -m sami_agent --config /etc/sami/config.yaml
```

## Servicio systemd

Copiar `service/sami-agent.service` a `/etc/systemd/system/sami-agent.service` y recargar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sami-agent
sudo systemctl start sami-agent
```

## Herramientas

`tools/dryrun_discovery.py` ejecuta sólo el descubrimiento de cámaras y muestra el resultado en JSON.

```bash
python tools/dryrun_discovery.py --config ./config.yaml
```

## Variables de entorno

El agente utiliza `PYTHONUNBUFFERED=1` en la unidad systemd para logs en tiempo real. No se requieren otras variables adicionales.
