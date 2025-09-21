#!/bin/bash

echo "🚀 Iniciando despliegue de MindCare..."

# Verificar que estemos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Instalar dependencias de Flutter
echo "📦 Instalando dependencias de Flutter..."
flutter pub get

# Construir la aplicación web
echo "🌐 Construyendo aplicación web..."
flutter build web

# Verificar que Firebase CLI esté instalado
if ! command -v firebase &> /dev/null; then
    echo "❌ Error: Firebase CLI no está instalado. Instálalo con: npm install -g firebase-tools"
    exit 1
fi

# Verificar que estemos logueados en Firebase
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Iniciando sesión en Firebase..."
    firebase login
fi

# Desplegar reglas de Firestore
echo "📋 Desplegando reglas de Firestore..."
firebase deploy --only firestore:rules

# Desplegar Cloud Functions
echo "⚡ Desplegando Cloud Functions..."
cd server/functions
npm install
npm run build
firebase deploy --only functions
cd ../..

# Desplegar hosting
echo "🌍 Desplegando hosting..."
firebase deploy --only hosting

echo "✅ ¡Despliegue completado exitosamente!"
echo "🎉 MindCare está ahora disponible en producción."
echo ""
echo "📱 Próximos pasos:"
echo "1. Configurar variables de entorno en Firebase Functions"
echo "2. Configurar webhooks de Stripe"
echo "3. Configurar Remote Config con precios regionales"
echo "4. Probar flujos de suscripción y reservas"
echo ""
echo "🔗 Documentación: docs/README.md"
