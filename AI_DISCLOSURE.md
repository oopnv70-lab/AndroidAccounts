# AI 修改声明 / AI Disclosure

> **重要：本仓库并非全部由 AI 编写。**
>
> 本项目（`com.rosan.accounts` / AndroidAccounts）的**原始代码由人类开发者 `iamr0s`
> 于 2023 年编写**（最后一次原始提交为 2023-07-19，提交信息 `tips: sui/shizuku not work`）。
> AI 只是在**保留原逻辑的前提下**做了**增量修复**，没有重写、没有删除既有功能。

本文件用于**如实列出 AI 参与的部分**，避免对仓库代码来源产生误解。

---

## 一、AI 参与的部分（逐条列出）

### 1. 修复 Android 17 上 `IUserManager.getUsers` 签名漂移导致的运行时崩溃

- **提交**：`76ade91` — *fix: 兼容 Android 17 上 IUserManager.getUsers 签名漂移（逐个尝试，纯加法）*
- **改动文件**：
  - **新增** `app/src/main/java/com/rosan/accounts/data/common/utils/UserManagerCompat.kt`（AI 新写）
  - **修改** `app/src/main/java/com/rosan/accounts/data/service/model/ShizukuUserService.kt`（仅替换 1 处调用点 + 1 行 import）
- **原报错**：
  ```
  No interface method getUsers(ZZZ)Ljava/util/List; in class Landroid/os/IUserManager;
  or its super classes (declaration of 'android.os.IUserManager' appears in
  /system/framework/framework.jar!classes3.dex)
  ```
- **根因（经实测 + 官方源码核实）**：AOSP 各分支的 `IUserManager.getUsers` AIDL 签名不一致：

  | AOSP 分支 | 签名 |
  |---|---|
  | `android15-release` / `android16-release` | `getUsers(boolean, boolean, boolean)` |
  | `android17-release` | `getUsers(boolean)` |
  | `master` / `HEAD` | `getUsers(boolean, boolean, boolean)` |

  项目原先按 `SDK_INT >= R` 硬编码调用 3 参数版本，在 Android 17 设备（实测：荣耀 MagicOS 11）
  上会因方法不存在而崩溃。
- **修复方式（纯加法，逐个尝试）**：新增 `UserManagerCompat.getUsersWithFallback()`，
  按顺序 `try` 三种签名（`ZZZ` → `Z` → `ZZZ` 变体），**全部失败才抛异常**。
  **原有分支逻辑一律保留**，没有任何删除。

### 2. 搭建 GitHub Actions 自动构建（APK 编译）

- **提交**：`0d3d6ff`、`9c25a88`、`bcf7ea7`、`4bc2a70`、`4e7e6fa`
- **改动文件**：
  - **新增** `.github/workflows/build.yml`（AI 新写）
  - **修改** `app/build.gradle`（签名配置的条件化，AI 修改）
  - **修改** `gradle.properties`（构建内存参数，AI 修改）
- **期间修复的问题**：
  1. `android-actions/setup-android@v3` 失败（`Failed to find package 'tools'`）→ 改为手动调用 runner 预装 SDK 的 `sdkmanager`。
  2. 通过 GitHub Contents API 写入 YAML 时换行被破坏 → 重写修复。
  3. **`:app:packageDebug` 报 `NullPointerException: SigningConfig "debug" is missing required property "storeFile"`**
     → 根因：`keystore/r0s.properties` 被 `.gitignore` 排除，CI 上没有该文件，
     但 `app/build.gradle` 无条件声明了 `signingConfigs.debug` 并将其挂到 `buildTypes.debug`，
     导致 AGP 内置的默认调试签名被覆盖、`storeFile` 为 `null`。
     → 修复：仅在 keystore **确实存在**时才声明/挂载自定义签名配置，
     否则完全交由 AGP 使用其内置默认调试签名（`~/.android/debug.keystore`，不存在时自动生成）。
  4. `gradle.properties` 中 `-Xmx2048m` 对 AGP 8.0.2 + Compose 偏小 → 提升为 `-Xmx4096m` 并加 `MaxMetaspaceSize`。
  5. workflow 增加 Gradle 缓存、`local.properties` 生成、失败时仍输出产物列表等。

---

## 二、AI **未**参与的部分（明确声明）

以下**全部为原作者 `iamr0s` 的原始代码**，AI **没有**改动其业务逻辑：

- `app/src/main/java/com/rosan/accounts/` 下除 `UserManagerCompat.kt` 与
  `ShizukuUserService.kt` 的那 1 处调用点外的**所有文件**
- `hidden-api/` 模块下的全部内容（`IUserManager.java`、`IAccountManager.java`、
  `IPackageManager.java`、`UserInfo.java`、`ServiceManager.java` 等）
- `app/src/main/res/`、`AndroidManifest.xml`、主题、UI 页面、Koin 依赖注入等
- 原有的 `build.gradle` / `settings.gradle` 结构、依赖版本、Compose 配置

**AI 的改动原则（应仓库所有者要求）：做加法，不做减法。**
即：只新增兜底分支与新文件，**不删除任何原有逻辑**，以保证旧版本 Android 设备继续可用。

---

## 三、AI 修改的完整提交记录

| 提交 | 说明 |
|---|---|
| `76ade91` | 修复 Android 17 上 `IUserManager.getUsers` 签名漂移（纯加法，逐个尝试） |
| `0d3d6ff` | 新增 GitHub Actions workflow（首版） |
| `9c25a88` | workflow：改用 runner 预装 SDK 的 sdkmanager |
| `bcf7ea7` | workflow：修复 YAML 换行损坏 |
| `4bc2a70` | 修复 keystore 缺失时的签名问题；调大构建内存；加缓存与 `local.properties` |
| `4e7e6fa` | 修复 `signingConfigs.debug` 覆盖 AGP 默认调试签名导致的 `:app:packageDebug` NPE ✅ 构建通过 |

---

## 四、致谢

- 原始项目与全部初始设计、实现：**`iamr0s`**（`271257581@qq.com`）
- 上游组件：[Shizuku](https://github.com/RikkaApps/Shizuku)、
  [Shizuku-API](https://github.com/RikkaApps/Shizuku-API)（RikkaApps）、
  [AndroidHiddenApiBypass](https://github.com/LSPosed/AndroidHiddenApiBypass)（LSPosed）
- AI 修复工作：由 **Operit** 协助完成（2026-09）。

---

*本声明遵循"如实披露"原则。如与实际提交记录不符，以 `git log` 为准。*
