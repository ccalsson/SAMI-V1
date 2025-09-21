class FirebaseConfig {
  // Configuración para Android
  static const String androidApiKey = 'AIzaSyBvEXAMPLE_KEY_FOR_ANDROID';
  static const String androidAppId = '1:123456789000:android:abcdef1234567890';
  static const String androidProjectId = 'mindcare-app';
  static const String androidStorageBucket = 'mindcare-app.appspot.com';
  static const String androidMessagingSenderId = '123456789000';
  static const String androidAuthDomain = 'mindcare-app.firebaseapp.com';

  // Configuración para iOS
  static const String iosApiKey = 'AIzaSyBvEXAMPLE_KEY_FOR_IOS';
  static const String iosAppId = '1:123456789000:ios:abcdef1234567890';
  static const String iosProjectId = 'mindcare-app';
  static const String iosStorageBucket = 'mindcare-app.appspot.com';
  static const String iosMessagingSenderId = '123456789000';
  static const String iosAuthDomain = 'mindcare-app.firebaseapp.com';

  // Configuración para Web
  static const String webApiKey = 'AIzaSyBvEXAMPLE_KEY_FOR_WEB';
  static const String webAppId = '1:123456789000:web:abcdef1234567890';
  static const String webProjectId = 'mindcare-app';
  static const String webStorageBucket = 'mindcare-app.appspot.com';
  static const String webMessagingSenderId = '123456789000';
  static const String webAuthDomain = 'mindcare-app.firebaseapp.com';

  // Configuración común
  static const String projectId = 'mindcare-app';
  static const String storageBucket = 'mindcare-app.appspot.com';
  static const String messagingSenderId = '123456789000';
  static const String authDomain = 'mindcare-app.firebaseapp.com';

  // Obtener configuración según plataforma
  static Map<String, dynamic> getConfig() {
    // En una implementación real, esto se determinaría en runtime
    // según la plataforma detectada
    return {
      'apiKey': androidApiKey,
      'authDomain': authDomain,
      'projectId': projectId,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
      'appId': androidAppId,
    };
  }
}
