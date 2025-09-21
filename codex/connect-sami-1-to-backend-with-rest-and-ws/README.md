# SAMI 1

Cliente Flutter para el panel SAMI con soporte REST, WebSocket y modo offline-first.

## Backend Setup

Configurar las variables de entorno en tiempo de compilación utilizando `--dart-define` (web/desktop/mobile). Ejemplos:

```bash
flutter run -d chrome \
  --dart-define=BASE_URL=https://sami-dev.company.local \
  --dart-define=WS_URL=wss://sami.company.com/ws \
  --dart-define=ENV=dev
```

Si no se indican valores, la app usa defaults seguros para `dev`/`prod`. Un `BASE_URL` vacío activa el modo demo con datos mock.

Variables disponibles:

- `BASE_URL`
- `WS_URL`
- `MQTT_BROKER`
- `ENV` (`dev`, `prod`, `demo`)

## Autenticación

Iniciar sesión con credenciales de backend (`username` + `password`). En modo demo se mantiene el usuario `ClaudioC / ABCD1234`.

Tokens y refresh tokens se guardan usando `flutter_secure_storage` (mobile/desktop) y localStorage cifrado (web). La app refresca tokens de forma automática al recibir un `401`.

## Modo Demo

Si `BASE_URL` está vacío se habilitan datos mock, WebSocket simulado y se deshabilitan acciones críticas.

## Offline y Sync

- Isar como base local para cache y cola de outbox.
- Cola de operaciones con retries exponenciales.
- Detecta conectividad y fuerza sync al volver online.
- Estrategia `cache-then-network` para listas.

Para inspeccionar la cola offline se puede abrir la pantalla `/debug` (en desarrollo) y forzar un sync manual.

## WebSocket y Alertas

Al iniciar sesión se establece una conexión WS a `WS_URL`. Si falla, la app usa polling cada `alertsPollingInterval` (configurable por `dart-define`). En modo demo se generan alertas periódicas.

## Módulos conectados

- **Alertas:** consulta, resolución optimista y actualizaciones en vivo via WS/polling (`/alerts`, `/alerts/{id}`, `/alerts/{id}/resolve`).
- **Cámaras:** listado con cache local y fallback demo (`/cameras`).
- **Combustible:** historial con estrategia cache-then-network y KPI semanal (`/fuel/events`, `/fuel/kpis`).
- **Herramientas:** estado de inventario y registro de movimientos con outbox offline (`/tools`, `/tools/movements`).
- **Operarios:** gestión básica con creación/actualización offline (`/operators`).
- **Proyectos:** alta y edición con sincronización automática (`/projects`).
- **Reportes:** descarga de CSV con guardado local multiplataforma (`/reports/*`).
- **Administración:** mantenimiento de usuarios/roles con guardas de rol (`/admin/users`, `/admin/roles`).

## KPIs en Dashboard

El panel principal muestra:

- Alertas activas de las últimas 24hs.
- Cámaras online.
- Litros de combustible consumidos en la semana (`/fuel/kpis?range=week`).
- Herramientas en uso en tiempo real.

Desde cada tarjeta se puede navegar a los listados completos de alertas, combustible, herramientas y proyectos.

## Reportes y Descargas

Los endpoints CSV están integrados en `ReportsRepository`. En mobile/desktop se guardan en el directorio de documentos usando `path_provider`. En web la descarga es directa.

## Scripts útiles

- `flutter pub get`
- `flutter pub run build_runner build --delete-conflicting-outputs` (para regenerar Isar si fuese necesario).
- `flutter test`

## Modo debug

Ruta `/debug` (en desarrollo) para revisar:

- Estado de conectividad.
- Tamaño de la cola offline.
- Último sync ejecutado.
- Versión de la app.

## Matriz de plataformas

| Feature | Web | Mobile | Desktop |
|---------|-----|--------|---------|
| REST / Auth | ✅ | ✅ | ✅ |
| WebSocket Alertas | ✅ | ✅ | ✅ |
| Modo Offline | ⚠️ (limitado) | ✅ | ✅ |
| Descarga Reportes | ✅ | ✅ | ✅ |
| Almacenamiento seguro | Cifrado localStorage | Secure Storage | Secure Storage |

> Nota: el modo offline en web está limitado por disponibilidad de APIs.
