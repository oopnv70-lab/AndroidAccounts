# AndroidAccounts

一个基于 **Shizuku** 的 Android 账号 / 用户管理应用（包名 `com.rosan.accounts`）。

- 用户管理：列出、删除多用户空间（`IUserManager`）
- 账号管理：查看各用户空间下的账号与账号认证器（`IAccountManager`）
- 依赖 [Shizuku](https://github.com/RikkaApps/Shizuku) / [Sui](https://github.com/RikkaApps/Sui)
  获取 shell / root 级 Binder 调用能力
- 通过 [AndroidHiddenApiBypass](https://github.com/LSPosed/AndroidHiddenApiBypass) 绕过隐藏 API 限制
- UI 使用 Jetpack Compose + Material 3，依赖注入使用 Koin

---

## ⚠️ AI 参与声明（务必阅读）

**本仓库并非全部由 AI 编写。**

| | |
|---|---|
| **原始代码** | 由人类开发者 **`iamr0s`** 于 **2023 年**编写（最后一次原始提交：2023-07-19） |
| **AI 参与** | 仅做**增量修复**，未重写、未删除原有逻辑 |
| **详细清单** | 见 **[AI_DISCLOSURE.md](AI_DISCLOSURE.md)** |

**AI 只做了两件事：**

1. **修复 Android 17 上的运行时崩溃**（`IUserManager.getUsers` 签名漂移）——
   AOSP `android17-release` 分支把 `getUsers(boolean, boolean, boolean)` 改成了 `getUsers(boolean)`，
   导致应用在 Android 17 设备上抛 `No interface method getUsers(ZZZ)...`。
   修复方式是**新增兜底分支逐个尝试**（`UserManagerCompat.kt`），**保留**原有 3 参数逻辑。

2. **搭建 GitHub Actions 自动构建**（`.github/workflows/build.yml`），
   并修复 CI 上因缺少 `keystore/r0s.properties` 导致的 `:app:packageDebug` 签名 NPE。

> 除上述以外（业务逻辑、UI、`hidden-api` 模块、资源文件、原有构建配置）
> **均为原作者代码，AI 未改动**。

---

## 构建

### 本地构建

```bash
./gradlew assembleDebug
```

输出：`app/build/outputs/apk/debug/*.apk`

> **签名说明**：若仓库根目录存在 `keystore/r0s.properties`（且其中 `storeFile` 指向的
> keystore 文件真实存在），则使用该自定义签名；否则自动回退为 AGP 内置的默认调试签名
> （`~/.android/debug.keystore`，不存在时会自动生成）。
> `keystore/` 目录已被 `.gitignore` 排除，不会提交到仓库。

### 云端构建（GitHub Actions）

推送代码到 `main` 分支，或手动触发 `Build APK` workflow：

1. 打开仓库 **Actions** 页 → 选择 **Build APK** → **Run workflow**
2. 构建完成后，在对应 run 的 **Artifacts** 中下载 `accounts-debug-apk`

---

## 环境要求

- 设备需安装并激活 **Shizuku**（或已 root 并安装 **Sui**）
- 首次打开应用需授予 Shizuku 权限
- 构建环境：JDK 17、Android SDK Platform 33、Build-Tools 33.0.2

---

## 目录结构

```
app/                          # 主应用模块
  src/main/java/com/rosan/accounts/
    data/common/utils/        # 工具类（含 AI 新增的 UserManagerCompat.kt）
    data/service/             # Shizuku 用户服务
    ui/                       # Compose UI
    di/                       # Koin 依赖注入
hidden-api/                   # 隐藏 API 的编译期桩（compileOnly，不打进 APK）
.github/workflows/build.yml   # AI 新增：GitHub Actions 构建
AI_DISCLOSURE.md              # AI 新增：AI 修改声明
```

---

## 许可与致谢

- 原始项目作者：**`iamr0s`**
- [Shizuku](https://github.com/RikkaApps/Shizuku) / [Shizuku-API](https://github.com/RikkaApps/Shizuku-API) — RikkaApps
- [AndroidHiddenApiBypass](https://github.com/LSPosed/AndroidHiddenApiBypass) — LSPosed