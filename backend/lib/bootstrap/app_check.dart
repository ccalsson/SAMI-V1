import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Initializes Firebase App Check for all supported platforms.
Future<void> initAppCheck() async {
  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: const String.fromEnvironment('APP_CHECK_SITE_KEY'),
    );
  } else {
    await FirebaseAppCheck.instance.activate();
  }
}
