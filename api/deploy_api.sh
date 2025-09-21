#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "Please export PROJECT_ID" >&2
  exit 1
fi

IMAGE=gcr.io/$PROJECT_ID/sami-api

npmbuild() {
  (cd api && npm install)
}

build() {
  gcloud builds submit --tag "$IMAGE" .
}

deploy() {
  gcloud run deploy sami-api \
    --image "$IMAGE" \
    --region=${REGION:-us-central1} \
    --set-env-vars "FIREBASE_PROJECT_ID=$PROJECT_ID" \
    --set-secrets "FIREBASE_SERVICE_ACCOUNT=sami-firebase-sa:latest" \
    --set-secrets "OPENAI_API_KEY=openai-key:latest" \
    --allow-unauthenticated
}

npmbuild
build
deploy
