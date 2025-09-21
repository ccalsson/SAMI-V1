# Add project specific ProGuard rules here.
# You can keep or remove the default templated content depending on your needs.

# Flutter wrapper keeps reflection heavy code, so keep the Flutter engine.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.stripe.** { *; }

-dontwarn android.support.**

