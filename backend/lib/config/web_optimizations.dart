import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'dart:html' as html;

class WebOptimizations {
  static void configure() {
    if (kIsWeb) {
      // Configurar service worker para caché
      if (html.window.navigator.serviceWorker != null) {
        html.window.navigator.serviceWorker!.register('/service-worker.js');
      }
      
      // Precargar recursos críticos
      _preloadCriticalAssets();
    }
  }

  static Future<void> _preloadCriticalAssets() async {
    final criticalImages = [
      'assets/images/logo.png',
      'assets/images/meditation_bg.jpg',
    ];

    for (var path in criticalImages) {
      final image = NetworkImage(path);
      await precacheImage(image, ContextProvider.context);
    }
  }
}

// Helper class to get a build context
class ContextProvider {
  static BuildContext? _context;

  static BuildContext get context {
    if (_context == null) {
      throw StateError('ContextProvider not initialized. Call setContext(context) first.');
    }
    return _context!;
  }

  static void setContext(BuildContext context) {
    _context = context;
  }
}
 