# SAMI 1

Prototipo multiplataforma para el Sistema de Alertas y Monitoreo Industrial (SAMI 1). La aplicación está construida con Flutter 3.24+, arquitectura modular, navegación con `go_router`, estado con Provider y persistencia local con Hive.

## Requisitos
- Flutter 3.24.0 o superior (Dart 3.x).
- Opcional: [FVM](https://fvm.app/) para gestionar versiones (`fvm use 3.24.0`).

## Instalación
```bash
flutter pub get
```

## Ejecución
- Web: `flutter run -d chrome`
- Android/iOS: `flutter run`
- Escritorio (macOS/Windows/Linux): `flutter run`

## Credenciales demo
- Usuario: `ClaudioC`
- Contraseña: `ABCD1234`

## Flujo básico
1. Inicia la app y selecciona **Iniciar sesión** desde la pantalla de bienvenida.
2. Ingresa las credenciales de prueba para acceder al dashboard.
3. Navega los distintos módulos desde la barra inferior (móvil) o el NavigationRail (escritorio).
4. En **Ajustes** puedes alternar el tema claro/oscuro, idioma y reiniciar la demo.

### Reiniciar la base local
En **Ajustes → Reiniciar demo** se borra la base Hive y se vuelve a sembrar toda la información mock (empresa, usuarios, alertas, etc.).

## Arquitectura
```
lib/
  core/        # routing, tema, utilidades
  data/        # modelos, repositorios e integración con Hive
  domain/      # entidades y casos de uso
  features/    # módulos funcionales (auth, dashboard, alerts, etc.)
  shared/      # providers y widgets compartidos
```
- `provider` para el manejo de estado.
- `go_router` para navegación con `StatefulShellRoute`.
- `Hive` como almacenamiento local offline-first.
- Hash de contraseñas con Argon2id (package `cryptography`).

## Scripts útiles
- `flutter pub get`
- `flutter run`
- `flutter test`
- `node scripts/seed.js`
- `node api/server.js`

## Configuración SAMI IA
1. Ajusta `config/sami.json` para editar modelos, voces soportadas y perfiles disponibles.
2. Define los `rtsp` y `device` reales en `defaults` o por organización (Firestore `/organizations/{orgId}/config/runtime`).
3. Establece la variable de entorno `OPENAI_API_KEY` para habilitar STT/TTS reales. Sin clave, el sistema opera en modo offline (respuestas simuladas).
4. Instala dependencias del backend local:
   ```bash
   cd api
   npm install
   cd ..
   ```

## Seeds demo
Ejecuta `node scripts/seed.js` para crear:
- Organizaciones **Aserradero Demo** (`industry.sawmill`) y **Verdulería Demo** (`retail.grocery`).
- Usuarios superuser/owner/admin/supervisor/operario con memberships.
- Cámaras y micrófonos dummy por organización.

El script es idempotente y registra cambios en `audit_logs`.

## Testing
Incluye pruebas unitarias para autenticación y repositorios básicos. Ejecuta:
```bash
flutter test
```

Pruebas Node (prompts, roles, menú, audio offline):
```bash
node --test core/__tests__/*.js
```

## Interacción con SAMI
- **Chat (roles superuser/owner/admin):** desde el dashboard, botón *Abrir chat*. Llama a `/api/chat` y muestra la respuesta de SAMI.
- **Audio (roles supervisor/operario):** botón *Hablar ahora*, graba con `record`, envía `/api/audio/in` y reproduce la respuesta TTS.

## Endpoints API (localhost:3333)
- `GET /api/orgs` lista organizaciones visibles.
- `GET /api/orgs/:id/profile` devuelve perfil activo, voz y auditoría.
- `PUT /api/orgs/:id/profile` (scope `profiles.manage`).
- `PUT /api/orgs/:id/voice` (scope `voice.manage`).
- `GET /api/orgs/:id/menu` genera menú dinámico por rol.
- `POST /api/chat`
- `POST /api/audio/in`

### Despliegue Cloud Run
```bash
export PROJECT_ID="mi-proyecto"
gcloud secrets create sami-firebase-sa --data-file=service-account.json
gcloud secrets create openai-key --data-file=openai.key
./api/deploy_api.sh
```

## SuperUser Console
- Accede a `/superuser/profiles` (requiere rol superuser).
- Selecciona la organización, aplica un perfil y voz.
- La acción actualiza módulos disponibles y registra el cambio en la auditoría.

## Notas
- El registro de usuarios está bloqueado para usuarios finales. El formulario de solicitud genera un ticket local que se almacena en Hive.
- Las descargas de reportes generan archivos mock (escritorio) o almacenan el contenido en memoria (web).
# SAMI.V1
