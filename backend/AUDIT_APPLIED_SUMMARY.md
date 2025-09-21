# Audit Applied Summary

| Checklist Item | Implementation |
| --- | --- |
| Biometric lock & session guard | `lib/security/biometric_lock.dart`, `lib/security/session_guard.dart` |
| MFA flow | `lib/auth/mfa_flow.dart`, `lib/screens/two_factor_setup_screen.dart` |
| Firebase App Check | `lib/bootstrap/app_check.dart`, README_SECURITY.md |
| Client-side encryption | `lib/security/client_crypto.dart`, `lib/services/emotion_repository.dart` |
| Firestore rules & tests | `firestore.rules`, `server/functions/test/firestore.rules.test.ts` |
| Cloud Functions audit & Stripe | `server/functions/src/security/auditLog.ts`, `server/functions/src/analytics/anonymize.ts`, `server/functions/src/stripe/webhooks.ts` |
| Rate limiting | `server/functions/src/security/rateLimit.ts` |
| UI screens | Files under `lib/screens/` including billing/history/upgrade |
| Legal docs | `legal/privacy.md`, `legal/terms.md` |
| CI/CD | `.github/workflows/*.yml`, `.github/dependabot.yml` |
| README & security docs | `README.md`, `README_SECURITY.md` |
| Build tweaks | `android/app/build.gradle.kts` (minSdk 26) |
| Env sample | `.env.sample` |
| Tests | `test/client_crypto_test.dart`, `server/functions/test/stripe.webhook.test.ts` |

## Commands
- Flutter: `flutter pub get`, `flutter analyze`, `flutter test`
- Functions: `npm --prefix server/functions install`, `npm --prefix server/functions test`
- Web build: `flutter build web`
- Deploy functions: `npm --prefix server/functions run deploy`

## Setup Steps
- Configure Firebase Project & enable App Check.
- Add secrets (`STRIPE_SECRET`, `STRIPE_WEBHOOK_SECRET`, `ANON_SALT`, `APP_CHECK_SITE_KEY`) in Firebase Secret Manager and GitHub.
- Enable MFA for admin/professional roles in Firebase Auth.
- In Stripe dashboard create webhook endpoint and use secret in `.env`.
