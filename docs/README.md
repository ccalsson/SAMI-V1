# MindCare - Documentación Técnica

## Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura](#arquitectura)
3. [Módulos](#módulos)
4. [Modelos de Datos](#modelos-de-datos)
5. [Servicios](#servicios)
6. [Sistema de Membresías](#sistema-de-membresías)
7. [IA Transversal](#ia-transversal)
8. [Base de Datos](#base-de-datos)
9. [Seguridad](#seguridad)
10. [Cloud Functions](#cloud-functions)
11. [Guía de Implementación](#guía-de-implementación)

## Descripción General
MindCare es una aplicación de bienestar mental con **IA transversal** que acompaña, guía y personaliza la experiencia del usuario sin reemplazar a los profesionales. La aplicación implementa un sistema de membresías graduales con precios segmentados por región.

## Arquitectura
- **Frontend**: Flutter (Android/iOS/Web)
- **Backend**: Firebase (Auth, Firestore, Storage, Remote Config, Functions)
- **Pagos**: Stripe con precios regionales
- **IA**: OpenAI GPT-4 con perfiles diferenciados
- **Arquitectura**: MVVM con Provider
- **Ruteo**: go_router

## Módulos

### 1. Bienestar
- Chat IA empático
- Estado de ánimo y seguimiento
- Música relajante y sonidos
- Técnicas de respiración y mindfulness
- Alimentación saludable

### 2. TDA/TDAH
- Ejercicios cortos de 2-5 minutos
- Técnicas de organización y rutinas
- Estrategias para padres y docentes
- Refuerzos positivos gamificados

### 3. Estudiantil
- Técnicas de estudio y organización
- Método Pomodoro y gestión del tiempo
- Manejo del estrés académico
- Explicaciones claras con IA

### 4. Desarrollo Profesional
- Evaluación de soft-skills
- Planes de desarrollo de 4 semanas
- Feedback 360° y autoevaluación
- Micro-lecciones y ejercicios prácticos

### 5. Profesionales de la Salud Mental
- Directorio verificado
- Disponibilidad en tiempo real
- Reservas con pago previo
- Chat/videollamada integrada
- Seguimiento IA pre/post consulta

## Sistema de Membresías

### Precios por Región

#### LATAM (USD)
- **Básica**: $5/mes - Módulo Bienestar
- **Full**: $10/mes - Bienestar + Alimentación + Chat IA (50 msgs/mes)
- **Premium**: $15/mes - Todo + TDA/TDAH + Estudiantil + Desarrollo Profesional + Acceso a Profesionales

#### Norteamérica (USD) y Europa (EUR)
- **Básica**: $10/mes o €10/mes - Módulo Bienestar
- **Full**: $15/mes o €15/mes - Bienestar + Alimentación + Chat IA (50 msgs/mes)
- **Premium**: $20/mes o €20/mes - Todo + TDA/TDAH + Estudiantil + Desarrollo Profesional + Acceso a Profesionales

### Entitlements
- **Básica**: módulo Bienestar
- **Full**: Bienestar + Alimentación saludable + Chat IA limitado
- **Premium**: Todo lo anterior + TDA/TDAH + Estudiantil + Desarrollo Profesional + Acceso al Directorio de Profesionales

## IA Transversal

### Perfiles de IA
- **Bienestar**: Coach empático para bienestar general
- **TDA/TDAH**: Especialista en TDA/TDAH
- **Estudiantil**: Coach académico
- **Desarrollo Profesional**: Coach de soft-skills
- **Pre-Consulta**: Preparación para consulta profesional
- **Post-Consulta**: Seguimiento post-consulta

### Características
- Lenguaje empático y directrices de seguridad
- "No reemplazo profesional" siempre presente
- Sugerencia de recursos y derivación si hay riesgo
- Guardado de resúmenes con consentimiento opt-in

## Modelos de Datos

### Usuario Extendido
```dart
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "Nombre Usuario",
  "country": "AR",
  "region": "latam",
  "studentFlag": false,
  "preferredModules": ["bienestar", "tda_tdh"],
  "guardianConsent": false,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### Profesional
```dart
{
  "uid": "prof_x",
  "name": "Dra. X",
  "license_number": "ABC123",
  "license_country": "AR",
  "verified": true,
  "verified_by": "admin_uid",
  "specialties": ["ansiedad", "tdah"],
  "languages": ["es", "en"],
  "rate_currency": "USD",
  "rate_amount": 50,
  "country": "AR",
  "city": "CABA",
  "telehealth": true,
  "bio": "Psicóloga clínica...",
  "rating": 4.8,
  "createdAt": timestamp
}
```

### Suscripción
```dart
{
  "id": "sub_1",
  "userId": "user_id",
  "type": "premium",
  "billingPeriod": "monthly",
  "region": "latam",
  "price": 15.0,
  "currency": "USD",
  "stripePriceId": "price_latam_premium",
  "startDate": timestamp,
  "endDate": timestamp,
  "isActive": true,
  "entitlements": ["bienestar", "alimentacion_saludable", "chat_ia_ilimitado", "tda_tdh", "estudiantil", "desarrollo_profesional", "profesionales"]
}
```

## Servicios

### Core Services
- **AiCoachService**: IA transversal con perfiles diferenciados
- **RemoteConfigService**: Configuración remota para precios y entitlements
- **StripeService**: Integración completa con Stripe
- **AuthProvider**: Gestión de autenticación y usuario
- **SubscriptionProvider**: Gestión de suscripciones y acceso
- **AiProvider**: Estado y contexto de IA

### Módulos
- **Bienestar**: Meditación, sonidos, alimentación
- **TDA/TDAH**: Ejercicios, rutinas, refuerzos
- **Estudiantil**: Planner, Pomodoro, técnicas de estudio
- **Desarrollo Profesional**: Evaluaciones, planes, feedback
- **Profesionales**: Directorio, reservas, pagos

## Base de Datos

### Colecciones Principales
- `users`: Usuarios con datos extendidos
- `professionals`: Directorio de profesionales verificados
- `availability`: Disponibilidad de profesionales
- `bookings`: Reservas de consultas
- `subscriptions`: Suscripciones activas
- `audio_resources`: Recursos de audio y meditación
- `modules_usage`: Uso de módulos (analytics opt-in)
- `ai_chat_summaries`: Resúmenes de chat IA

### Reglas de Seguridad
- Usuarios solo pueden acceder a sus propios datos
- Profesionales son de lectura pública
- Reservas solo para usuarios autenticados
- Contenido premium según entitlements
- Admins pueden verificar profesionales

## Cloud Functions

### Funciones Principales
- **syncPrices**: Sincroniza precios de Stripe por región
- **createBooking**: Crea reserva y PaymentIntent
- **webhookStripe**: Procesa webhooks de Stripe
- **verifyProfessional**: Verificación de profesionales (admin)
- **syncProfessionalAvailability**: Sincroniza disponibilidad

### Configuración
- Node.js 18+
- Firebase Admin SDK
- Stripe SDK
- CORS habilitado

## Guía de Implementación

### 1. Configuración Inicial
```bash
# Instalar dependencias
flutter pub get

# Configurar Firebase
firebase init

# Configurar variables de entorno
cp env.example .env
# Editar .env con tus claves
```

### 2. Configuración de Stripe
```bash
# Configurar webhook secret
firebase functions:config:set stripe.webhook_secret="whsec_xxx"

# Desplegar funciones
firebase deploy --only functions
```

### 3. Configuración de Remote Config
```json
{
  "region_default": "latam",
  "plans_json": { /* estructura de precios */ },
  "entitlements_json": { /* estructura de entitlements */ }
}
```

### 4. Despliegue
```bash
# Desplegar reglas de Firestore
firebase deploy --only firestore:rules

# Desplegar funciones
firebase deploy --only functions

# Desplegar aplicación
flutter build web
firebase deploy --only hosting
```

## Estándares de Calidad

### Testing
- **Unit**: EntitlementsGuard, RegionResolver
- **Widget**: Paywall, navegación
- **Integration**: Flujo de reserva completo

### Linting
- `flutter_lints` sin warnings
- Análisis estático limpio
- Formato consistente

### Accesibilidad
- Tamaños de texto apropiados
- Contraste adecuado
- Labels descriptivos
- Navegación por teclado

## Roadmap

### Fase 1 (MVP) ✅
- [x] Estructura modular
- [x] Sistema de suscripciones
- [x] IA transversal básica
- [x] Paywall regional
- [x] Cloud Functions

### Fase 2 (Desarrollo)
- [ ] Implementación completa de módulos
- [ ] Chat IA avanzado
- [ ] Sistema de notificaciones
- [ ] Analytics y métricas

### Fase 3 (Escalabilidad)
- [ ] Múltiples idiomas
- [ ] Integración con wearables
- [ ] API pública
- [ ] Marketplace de contenido

## Soporte y Contacto

Para soporte técnico o consultas sobre la implementación:
- Crear issue en el repositorio
- Documentación detallada en `/docs`
- Ejemplos de código en `/examples`

---

**MindCare** - Tu compañero de bienestar mental con IA transversal 🧠✨