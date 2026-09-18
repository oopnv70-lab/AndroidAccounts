# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# ============================================================
# [add] AI 补充的 keep 规则（release 开启了 minifyEnabled true，
#       原先本文件为空，Shizuku / 隐藏 API / Koin(反射) 会被裁掉，
#       导致 release 版运行时崩溃。以下均为增量规则，不改动原逻辑。）
# ============================================================

# ---------- 1. Shizuku / Sui ----------
# Shizuku 通过 AIDL + 反射与远程服务通信，类名/方法名不能被混淆。
-keep class rikka.shizuku.** { *; }
-keep class dev.rikka.shizuku.** { *; }
-keep class moe.shizuku.** { *; }
-dontwarn rikka.shizuku.**
-dontwarn dev.rikka.shizuku.**
-dontwarn moe.shizuku.**

# ---------- 2. 隐藏 API 调用兜底 ----------
# 说明：hidden-api 模块以 compileOnly 引入，其中的 android.* 桩类不会打进 APK，
#       运行时由系统 framework 提供，R8 对 android.* 有内置白名单，无需 keep。
#       这里只对可能的反射调用做兜底（无害，且防止未来改成反射调用时被裁）。
-dontwarn android.os.IUserManager
-dontwarn android.os.ServiceManager
-dontwarn android.accounts.IAccountManager
-dontwarn android.content.pm.IPackageManager

# ---------- 3. AndroidHiddenApiBypass (LSPosed) ----------
# 该库靠反射调用被隐藏的 API，类与方法名必须保留。
-keep class org.lsposed.hiddenapibypass.** { *; }
-dontwarn org.lsposed.hiddenapibypass.**

# ---------- 4. Koin（运行时反射注入） ----------
-keep class org.koin.** { *; }
-dontwarn org.koin.**

# ---------- 5. Kotlin 元数据 / 反射相关 ----------
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*, InnerClasses, Signature, Exceptions, SourceFile, LineNumberTable
-keepclassmembers class kotlinx.coroutines.** { volatile <fields>; }
-dontwarn kotlinx.coroutines.**

# ---------- 6. 应用自身（保留入口与 AIDL/Stub 实现） ----------
# 保留 application / Activity / Service 中通过 manifest. 反射实例化的类。
-keep class com.rosan.accounts.App { *; }
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.Activity
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ---------- 7. 保留用户服务入口（ShizukuUserService 远程绑定，按反射/类名加载） ----------
-keep class com.rosan.accounts.data.service.model.ShizukuUserService { *; }
-keep class com.rosan.accounts.data.service.** { *; }
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

-keep public interface ** extends android.os.IInterface {*;}
-keep public class ** extends android.app.Activity

-dontwarn **
