# Keep required classes for Amplify and Tink
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }
-keep class com.amplifyframework.** { *; }
-keep class com.amazonaws.** { *; }

# Keep Amplify generated classes
-keep class com.amplifyframework.** { *; }
-keep class com.amazonaws.** { *; }

# Keep Tink crypto classes
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.crypto.tink.proto.** { *; }

# Keep annotation classes
-keep @interface com.google.errorprone.annotations.** { *; }
-keep @interface javax.annotation.** { *; }
-keep @interface javax.annotation.concurrent.** { *; }

# Keep Flutter specific classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Amplify secure storage
-keep class com.amplifyframework.storage.** { *; }

# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Google API Client classes
-keep class com.google.api.client.** { *; }
-keep class com.google.api.client.http.** { *; }
-keep class com.google.api.client.http.javanet.** { *; }

# Keep Joda Time classes
-keep class org.joda.time.** { *; }

# Keep all annotation classes
-keep @interface * { *; }

# Keep all classes with specific annotations
-keep @com.google.errorprone.annotations.CanIgnoreReturnValue class * { *; }
-keep @com.google.errorprone.annotations.CheckReturnValue class * { *; }
-keep @com.google.errorprone.annotations.Immutable class * { *; }
-keep @com.google.errorprone.annotations.InlineMe class * { *; }
-keep @com.google.errorprone.annotations.RestrictedApi class * { *; }
-keep @javax.annotation.Nullable class * { *; }
-keep @javax.annotation.concurrent.GuardedBy class * { *; }
-keep @javax.annotation.concurrent.ThreadSafe class * { *; }

# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep Amplify
-keep class com.amplifyframework.** { *; }
-keep class com.amazonaws.** { *; }
-keep class software.amazon.awssdk.** { *; }

# Keep Google Play Services (if needed)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google API Client
-keep class com.google.api.client.** { *; }
-keep class com.google.api.services.** { *; }

# Keep Google Crypto Tink
-keep class com.google.crypto.tink.** { *; }

# Keep Joda Time
-keep class org.joda.time.** { *; }

# Keep Error Prone annotations
-keep class com.google.errorprone.annotations.** { *; }

# Keep Javax annotations
-keep class javax.annotation.** { *; }

# Keep Excel library
-keep class org.apache.poi.** { *; }

# Keep WebView
-keep class android.webkit.** { *; }

# Keep URL Launcher
-keep class androidx.browser.** { *; }

# Keep Shared Preferences
-keep class androidx.preference.** { *; }

# Keep Path Provider
-keep class androidx.documentfile.** { *; }

# Keep Package Info Plus
-keep class dev.fluttercommunity.plus.package_info.** { *; }

# Keep Flutter Color Picker
-keep class flutter.plugins.colorpicker.** { *; }

# Keep Flutter Phoenix
-keep class com.jaumard.flutter_phoenix.** { *; }

# Keep Intl
-keep class com.google.i18n.** { *; }

# Keep MySQL
-keep class com.mysql.** { *; }

# Keep Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Remove unused classes and methods
-dontwarn org.jetbrains.annotations.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.**
-dontwarn javax.annotation.**
-dontwarn org.joda.time.**

# Optimize
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Additional rules for missing classes
-dontwarn com.google.android.play.core.**
-dontwarn com.google.api.client.**
-dontwarn com.google.crypto.tink.**
-dontwarn javax.annotation.**
-dontwarn org.joda.time.**

# Keep all classes that might be referenced by reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep classes that might be used by the Android framework
-keep class android.support.** { *; }
-keep class androidx.** { *; }

# Keep all classes in packages that might be used by the app
-keep class com.google.** { *; }
-keep class org.apache.** { *; }
-keep class org.joda.** { *; }
-keep class javax.** { *; } 