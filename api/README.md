# SAMI API

Backend Express que expone los endpoints multi-perfil de SAMI.

## Ejecutar localmente
```bash
cd api
npm install
FIREBASE_PROJECT_ID=your-project OPENAI_API_KEY=sk-... node server.js
```
Requiere un archivo de credenciales de servicio (JSON) y definir `FIREBASE_SERVICE_ACCOUNT=/ruta/al/archivo.json`.

## Despliegue en Cloud Run
1. Guarda la credencial en Secret Manager:
   ```bash
   gcloud secrets create sami-firebase-sa --data-file=service-account.json
   ```
2. Construye y publica la imagen:
   ```bash
   gcloud builds submit --tag gcr.io/$PROJECT_ID/sami-api .
   ```
3. Despliega:
   ```bash
   gcloud run deploy sami-api \
     --image gcr.io/$PROJECT_ID/sami-api \
     --set-env-vars FIREBASE_PROJECT_ID=$PROJECT_ID,OPENAI_API_KEY=projects/$PROJECT_ID/secrets/openai-key:latest \
     --set-secrets FIREBASE_SERVICE_ACCOUNT=sami-firebase-sa:latest \
     --allow-unauthenticated
   ```
4. Configura CORS/apikey según política interna.

## Endpoints
- `GET /orgs`
- `GET /orgs/:id/profile`
- `PUT /orgs/:id/profile`
- `PUT /orgs/:id/voice`
- `GET /orgs/:id/menu`
- `POST /chat`
- `POST /audio/in`
