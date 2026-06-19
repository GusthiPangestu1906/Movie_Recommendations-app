# Flutter ProGuard Rules

# Prevent R8 from complaining about missing Play Core classes
-dontwarn com.google.android.play.core.**

# Preserve data models from being obfuscated
-keep class com.example.mymovies.models.** { *; }

# Generic Flutter preservation
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
