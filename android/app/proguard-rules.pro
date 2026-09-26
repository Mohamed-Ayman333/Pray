# ---- Gson keep rules (required by flutter_local_notifications) ----
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-dontwarn sun.misc.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** {
    <fields>;
    <methods>;
}
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ---- WorkManager keep rules (required by workmanager plugin) ----
# R8 strips WorkDatabase_Impl because it's only created via reflection.
# Without these rules, the app crashes on startup with:
#   "Failed to create an instance of class androidx.work.impl.WorkDatabase"
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.work.ListenableWorker {
    <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keep class * extends androidx.work.InputMerger { <init>(); }