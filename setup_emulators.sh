#!/bin/bash

echo "🚀 Configurando MindCare para emuladores..."

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no está instalado o no está en el PATH"
    echo "Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Verificar que Android Studio esté instalado
if ! command -v adb &> /dev/null; then
    echo "❌ Error: Android SDK no está instalado o no está en el PATH"
    echo "Instala Android Studio desde: https://developer.android.com/studio"
    exit 1
fi

# Verificar que Xcode esté instalado (solo en macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Error: Xcode no está instalado"
        echo "Instala Xcode desde la App Store"
        exit 1
    fi
fi

echo "✅ Dependencias verificadas"

# Instalar dependencias de Flutter
echo "📦 Instalando dependencias de Flutter..."
flutter pub get

# Verificar dispositivos disponibles
echo "📱 Verificando dispositivos disponibles..."
flutter devices

# Función para iniciar emulador Android
start_android_emulator() {
    echo "🤖 Iniciando emulador Android..."
    
    # Listar emuladores disponibles
    echo "Emuladores Android disponibles:"
    emulator -list-avds
    
    # Si no hay emuladores, crear uno
    if ! emulator -list-avds | grep -q "mindcare_emulator"; then
        echo "Creando emulador Android..."
        avdmanager create avd -n mindcare_emulator -k "system-images;android-34;google_apis;x86_64"
    fi
    
    # Iniciar emulador
    emulator -avd mindcare_emulator &
    
    # Esperar a que el emulador esté listo
    echo "Esperando a que el emulador esté listo..."
    adb wait-for-device
    
    # Verificar que esté funcionando
    adb shell getprop sys.boot_completed
    while [ "$(adb shell getprop sys.boot_completed)" != "1" ]; do
        sleep 5
    done
    
    echo "✅ Emulador Android iniciado"
}

# Función para iniciar simulador iOS (solo en macOS)
start_ios_simulator() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 Iniciando simulador iOS..."
        
        # Listar simuladores disponibles
        echo "Simuladores iOS disponibles:"
        xcrun simctl list devices
        
        # Iniciar simulador iPhone 15
        xcrun simctl boot "iPhone 15"
        open -a Simulator
        
        echo "✅ Simulador iOS iniciado"
    else
        echo "ℹ️  Simulador iOS solo disponible en macOS"
    fi
}

# Función para ejecutar la aplicación
run_app() {
    echo "🎯 Ejecutando MindCare..."
    
    # Verificar dispositivos conectados
    flutter devices
    
    # Ejecutar en modo debug
    flutter run --debug
}

# Menú principal
echo ""
echo "🎮 ¿Qué emulador quieres usar?"
echo "1. Android"
echo "2. iOS (solo macOS)"
echo "3. Ambos"
echo "4. Solo ejecutar (si ya tienes emuladores corriendo)"
echo "5. Salir"
echo ""

read -p "Selecciona una opción (1-5): " choice

case $choice in
    1)
        start_android_emulator
        run_app
        ;;
    2)
        start_ios_simulator
        run_app
        ;;
    3)
        start_android_emulator
        start_ios_simulator
        run_app
        ;;
    4)
        run_app
        ;;
    5)
        echo "👋 ¡Hasta luego!"
        exit 0
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

echo ""
echo "🎉 MindCare está ejecutándose en el emulador!"
echo ""
echo "📱 Próximos pasos:"
echo "1. Configura Firebase con tus claves reales"
echo "2. Configura Stripe con tus claves de prueba"
echo "3. Prueba la funcionalidad de suscripciones"
echo "4. Prueba el chat IA en diferentes módulos"
echo ""
echo "🔗 Documentación: docs/README.md"
echo "🚀 Script de despliegue: ./deploy.sh"
