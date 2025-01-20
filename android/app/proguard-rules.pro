# Play Core
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep interface com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Suppress warnings related to missing Google Play Core task classes
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.reslocate.new.** { *; }

# Keep url_launcher
-keep class androidx.core.content.FileProvider
-keep class androidx.core.content.FileProvider$PathStrategy

# For URL Launcher
-keep class com.google.android.gms.common.ConnectionResult {
    int SUCCESS;
}
-keep class com.google.android.gms.** { *; }
-keep class androidx.browser.** { *; }
-keep class androidx.core.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}