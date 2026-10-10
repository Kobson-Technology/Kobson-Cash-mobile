# Flutter — keep classes used via reflection / JNI
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.**

# Dart / JNI entry points
-keep class com.kobsontech.kobson_cash.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# HTTP / networking
-dontwarn okhttp3.**
-dontwarn okio.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
