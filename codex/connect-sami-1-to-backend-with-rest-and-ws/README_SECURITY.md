# Security Guide

Overview of security hardening for MindCare.

## Firebase MFA
- Enable multi-factor authentication (SMS/TOTP) in Firebase console for admin and professional roles.
- The app includes `TwoFactorSetupScreen` and helpers in `lib/auth/mfa_flow.dart`.

## Biometric Lock and Session Guard
- `lib/security/biometric_lock.dart` implements optional biometric unlock and secure token storage.
- `lib/security/session_guard.dart` provides inactivity timeout and reauthentication hooks.

## Client-side Encryption
- Sensitive emotion entries can be encrypted using `lib/security/client_crypto.dart`.

## Firestore Rules
- Rules are defined in `firestore.rules` with role-based access control.
- Tests: `cd server/functions && npm test`.

## Cloud Functions
- Rate limiting, audit logs, anonymized analytics and Stripe webhooks live under `server/functions/src`.

## Environment / Secrets
Use Firebase Secret Manager to store:
- `STRIPE_SECRET`
- `STRIPE_WEBHOOK_SECRET`
- `RECAPTCHA_SECRET`
- `ANON_SALT`
- `APP_CHECK_SITE_KEY` (web)

Enable App Check in Firebase console for Android/iOS (DeviceCheck/PlayIntegrity)
and use the above site key for web reCAPTCHA.

Sensitive login/registration forms should also include reCAPTCHA v3 or rely on
App Check tokens to mitigate automated abuse.

Create a `.env` from `.env.sample` and load into Secret Manager as needed.
These variables should also be configured as GitHub Action secrets for CI/CD.

## Audit & Rate Limiting
- Audit logs for emotion writes: `server/functions/src/security/auditLog.ts`.
- Rate limiting example: `server/functions/src/security/rateLimit.ts`.

## Data Access
- Users can request export or deletion of their data in compliance with GDPR and Ley 25.326.

## Setup Commands
```bash
flutter pub get
cd server/functions && npm install
```
