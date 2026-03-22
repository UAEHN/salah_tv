# flutter_local_notifications — keep all receiver/service classes used via reflection
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }

# Keep BroadcastReceivers registered in AndroidManifest (called by the OS at boot/alarm time)
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Service

# Gson (used internally by flutter_local_notifications for notification serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# timezone (dart timezone package native bridge)
-keep class com.google.androidbrowserhelper.** { *; }

# General Flutter keep rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Store deferred components — not used in this app, suppress missing-class warnings
-dontwarn com.google.android.play.core.**
