# ---- Gson keep rules (required by flutter_local_notifications) ----
# Gson relies on reflection over generic type signatures. R8 strips those
# by default, which causes "Missing type parameter" at runtime in release
# builds.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Gson's reflection infrastructure.
-dontwarn sun.misc.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# ---- flutter_local_notifications keep rules ----
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** {
    <fields>;
    <methods>;
}

# Preserve generic collection info used by Gson deserialization.
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}