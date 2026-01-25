# =========================
# FLUTTER & DART
# =========================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# =========================
# GOOGLE PLAY CORE (Optional - untuk dynamic features)
# =========================
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# =========================
# FLUTTER LOCAL NOTIFICATIONS (PENTING!)
# =========================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep interface com.dexterous.flutterlocalnotifications.** { *; }

# Preserve Gson type information
-keepclassmembers class * {
    <init>(...);
}
-keep class com.google.gson.** { *; }
-keepclassmembers class com.google.gson.** {
    <fields>;
    <methods>;
}

# Preserve generic types
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes LineNumberTable
-keepattributes SourceFile

# =========================
# TIMEZONE LIBRARY
# =========================
-keep class org.joda.time.** { *; }
-keep interface org.joda.time.** { *; }

# =========================
# YOUR APP PACKAGE
# =========================
-keep class com.wisnufebri.quran.app.** { *; }
-keep interface com.wisnufebri.quran.app.** { *; }

# =========================
# AUDIO SERVICE
# =========================
-keep class com.ryanheise.audioservice.** { *; }
-keep interface com.ryanheise.audioservice.** { *; }

# =========================
# PERMISSION HANDLER
# =========================
-keep class com.baseflow.permissionhandler.** { *; }

# =========================
# NATIVE METHODS
# =========================
-keepclasseswithmembernames class * {
    native <methods>;
}

# =========================
# ENUMS
# =========================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# =========================
# SERIALIZABLE
# =========================
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# =========================
# VIEW HOLDERS
# =========================
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# =========================
# REMOVE LOGGING IN RELEASE
# =========================
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}