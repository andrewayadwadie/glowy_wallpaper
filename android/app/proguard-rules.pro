# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# AdMob
-keep class com.google.android.gms.ads.** { *; }

# Hive
-keep class com.hivedb.** { *; }

# Keep app entry point
-keep class com.glowy.wallpaper.** { *; }

# Kotlin
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Play Core
-dontwarn com.google.android.play.core.**
