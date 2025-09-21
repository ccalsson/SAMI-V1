# SAMI · Etapa 1 – Fundamentos multi-tenant

## 1. Configuración central
- `config/sami.json` contiene modelos, voces soportadas, reglas de ruteo por rol y **perfiles de industria** con tono, módulos, focos, reportes y prompt base.
- Cámaras y micrófonos se definen como `defaults` para mantener compatibilidad hasta que cada organización declare sus propios recursos.
- Perfil activo se guardará por organización en Firestore (`/organizations/{orgId}/config/active_profile`).

## 2. Núcleo SAMI (Node)
- `core/brain.js` ahora resuelve hardware desde `defaults` si no se configura por organización.
- `core/prompts.js` genera el system prompt combinando persona por perfil + reglas globales + contexto dinámico.
- `core/roles.js` define scopes por rol y helper `checkScope()` reutilizable en backend y UI.

## 3. Pasos siguientes (Etapa 2)
1. Extender `brain`, `interaction`, `audio`, `reports` para cargar perfil activo desde Firestore y aplicar `persona_prompt`, voz y módulos.
2. Incorporar `core/menu_registry.js`, `core/menu_runtime.js` y `/core/modules/*` con builder de rutas dinámicas.
3. Exponer endpoints (`GET/PUT /orgs/:id/profile`, `/voice`, `/menu`, `/chat`, `/audio/in`).
4. Añadir enforcer de permisos en backend usando `checkScope` y revisar reglas de Firestore.

Con esta base se cubren los cimientos para el tuneo por industria y la administración multi-tenant.
