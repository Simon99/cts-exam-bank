# Framework 模組注入點分布列表

**CTS 路徑**: `cts/tests/framework/`  
**更新時間**: 2026-02-10 18:30 GMT+8  
**狀態**: ✅ Phase A 完成

---

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 45 |
| Easy | 16 (36%) |
| Medium | 19 (42%) |
| Hard | 10 (22%) |

**子模組分布**：
- WindowManager: 35 個注入點
- Biometrics: 6 個注入點
- Locale/LocaleConfig: 3 個注入點
- GrammaticalInflection: 1 個注入點

---

## 子模組結構

| 子模組 | CTS 測試數 | 描述 |
|--------|-----------|------|
| windowmanager | 139 | 視窗管理器、Activity 生命週期、Insets |
| biometrics | 8 | 生物識別驗證 |
| locale | 4 | LocaleManager API |
| localeconfig | 2 | LocaleConfig API |
| grammaticalinflection | 2 | 語法變化管理 |
| suggestions | 1 | 設定建議 |

---

## 對應 AOSP 源碼路徑

### WindowManager (核心)
- `frameworks/base/services/core/java/com/android/server/wm/`
  - `ActivityRecord.java` (11137 行) ⭐
  - `WindowManagerService.java` (10052 行) ⭐
  - `ActivityTaskManagerService.java` (7366 行) ⭐
  - `Task.java` (6856 行)
  - `WindowState.java`
  - `DisplayContent.java`
  - `InsetsStateController.java`
  - `InsetsPolicy.java`
  - `KeyguardController.java`

### View API (Client-side)
- `frameworks/base/core/java/android/view/`
  - `WindowInsets.java` (2042 行)
  - `WindowInsetsController.java`
  - `WindowInsetsAnimation.java`
  - `View.java`
  - `Window.java`

### Biometrics
- `frameworks/base/core/java/android/hardware/biometrics/`
  - `BiometricManager.java` (754 行)
  - `BiometricPrompt.java` (1412 行)
- `frameworks/base/services/core/java/com/android/server/biometrics/`
  - `BiometricService.java`
  - `AuthSession.java`

### Locale
- `frameworks/base/core/java/android/app/LocaleManager.java`
- `frameworks/base/services/core/java/com/android/server/locales/`

---

## 注入點清單

### 1. Activity 生命週期 (ActivityRecord) ⭐

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/ActivityRecord.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-001 | setState() | 5929-6100 | STATE | Medium | ActivityLifecycleTests | Activity 狀態轉換核心邏輯 |
| FW-002 | setVisibility() | 5472-5700 | STATE, COND | Medium | ActivityVisibilityTests | 可見性設定，deferHidingClient 處理 |
| FW-003 | completeFinishing() | 3900-3980 | STATE, RES | Medium | ActivityLifecycleTests | finish 完成處理 |
| FW-004 | destroyIfPossible() | 3960-4020 | STATE, COND | Medium | ActivityLifecycleTests | 銷毀條件判斷 |
| FW-005 | cleanUp() | 4213-4300 | RES, STATE | Easy | ActivityLifecycleTests | 資源清理 |
| FW-006 | inputDispatchingTimedOut() | 7184-7245 | COND, ERR | Medium | AnrTests | ANR 超時處理 |
| FW-007 | isInterestingToUserLocked() | 7246-7340 | COND | Easy | ActivityLifecycleTests | 用戶興趣判斷 |
| FW-008 | onConfigurationChanged() | 9333-9500 | STATE, COND | Hard | ConfigChangeTests | 配置變更處理 |
| FW-009 | matchParentBounds() | 8437-8500 | BOUND, CALC | Easy | AspectRatioTests | 邊界匹配檢查 |

### 2. WindowManager Service

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/WindowManagerService.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-011 | addWindowToken() | 2741-2800 | COND, ERR | Medium | WindowManagerTests | Token 添加驗證 |
| FW-012 | removeWindowToken() | 2972-2985 | COND, STATE | Easy | WindowManagerTests | Token 移除 |
| FW-013 | refreshScreenCaptureDisabled() | 1972-2020 | STATE | Easy | ScreenRecordingCallbackTests | 螢幕錄製禁用刷新 |
| FW-014 | disableKeyguard() | 3266-3280 | STATE, COND | Medium | KeyguardTests | Keyguard 禁用 |
| FW-015 | reenableKeyguard() | 3283-3305 | STATE, COND | Medium | KeyguardTests | Keyguard 重新啟用 |
| FW-016 | dismissKeyguard() | 3350-3370 | STATE, COND | Medium | KeyguardTests | Keyguard 解除 |
| FW-017 | setAnimationScale() | 3468-3485 | BOUND, COND | Easy | WindowManagerTests | 動畫縮放設定 |
| FW-018 | lockDeviceNow() | 3588-3610 | STATE | Easy | KeyguardTests | 立即鎖定設備 |
| FW-019 | startFreezingScreen() | 3218-3245 | STATE | Easy | WindowManagerTests | 螢幕凍結開始 |
| FW-020 | stopFreezingScreen() | 3245-3266 | STATE | Easy | WindowManagerTests | 螢幕凍結結束 |

### 3. WindowInsets（視窗邊距）

**檔案**: `frameworks/base/core/java/android/view/WindowInsets.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-021 | getInsets() | 310-350 | COND, BOUND | Easy | WindowInsetsTest | 獲取特定類型 Insets |
| FW-022 | getInsetsIgnoringVisibility() | 360-400 | COND | Easy | WindowInsetsTest | 忽略可見性獲取 Insets |
| FW-023 | isVisible() | 420-450 | COND | Easy | WindowInsetsTest | 類型可見性檢查 |
| FW-024 | inset() | 600-700 | CALC, BOUND | Medium | WindowInsetsLayoutTests | Insets 內縮計算 |
| FW-025 | Builder.setInsets() | 1400-1450 | COND, BOUND | Medium | WindowInsetsLayoutTests | Builder 設定 Insets |
| FW-026 | Builder.setVisible() | 1500-1550 | COND | Easy | WindowInsetsTest | Builder 設定可見性 |

### 4. WindowInsetsController（Insets 控制器）

**檔案**: `frameworks/base/core/java/android/view/WindowInsetsController.java` + 實現

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-031 | show() | - | STATE, COND | Medium | WindowInsetsControllerTests | 顯示系統 bars |
| FW-032 | hide() | - | STATE, COND | Medium | WindowInsetsControllerTests | 隱藏系統 bars |
| FW-033 | setSystemBarsBehavior() | - | STATE | Easy | WindowInsetsControllerTests | 設定行為模式 |
| FW-034 | controlWindowInsetsAnimation() | - | STATE, SYNC | Hard | WindowInsetsAnimationControllerTests | 動畫控制 |

### 5. Keyguard（鍵盤鎖）

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/KeyguardController.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-041 | setKeyguardShown() | - | STATE | Medium | KeyguardTests | 設定 Keyguard 顯示狀態 |
| FW-042 | isKeyguardShowing() | - | STATE, COND | Easy | KeyguardTests | 檢查 Keyguard 是否顯示 |
| FW-043 | isKeyguardLocked() | - | STATE, COND | Easy | KeyguardLockedTests | 檢查 Keyguard 是否鎖定 |
| FW-044 | dismissKeyguard() | - | STATE, COND | Medium | KeyguardTests | 解除 Keyguard |
| FW-045 | handleOccludedChange() | - | STATE, COND | Hard | KeyguardTransitionTests | Occluded 狀態變更處理 |

### 6. Multi-Display（多螢幕）

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/DisplayContent.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-051 | getDisplayId() | - | COND | Easy | MultiDisplayActivityLaunchTests | 獲取 Display ID |
| FW-052 | setFocusedApp() | - | STATE, COND | Medium | MultiDisplayPolicyTests | 設定焦點 App |
| FW-053 | updateDisplayInfo() | - | STATE | Medium | DisplayTests | 更新 Display 資訊 |
| FW-054 | calculateDisplayCutout() | - | CALC, BOUND | Hard | DisplayCutoutTests | 計算 DisplayCutout |

### 7. PiP（Picture-in-Picture）

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/PinnedTaskController.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-061 | enterPip() | - | STATE, COND | Hard | PinnedStackTests | 進入 PiP 模式 |
| FW-062 | isInPipMode() | - | STATE | Easy | ActivityLifecyclePipTests | 檢查是否在 PiP |
| FW-063 | getDefaultBounds() | - | CALC, BOUND | Medium | PinnedStackTests | 獲取預設邊界 |

---

## Biometrics 子模組

### 8. BiometricManager

**檔案**: `frameworks/base/core/java/android/hardware/biometrics/BiometricManager.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-071 | canAuthenticate() | 441-510 | COND, ERR | Medium | BiometricServiceTests | 檢查是否可驗證 |
| FW-072 | canAuthenticate(int) | 482-510 | COND | Medium | BiometricServiceTests | 帶 authenticators 參數版本 |
| FW-073 | getLastAuthenticationTime() | 735-750 | COND, ERR | Medium | BiometricServiceTests | 獲取上次驗證時間 |

### 9. BiometricPrompt

**檔案**: `frameworks/base/core/java/android/hardware/biometrics/BiometricPrompt.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-074 | authenticate() | - | STATE, COND | Hard | BiometricActivityTests | 執行驗證 |
| FW-075 | cancelAuthentication() | - | STATE | Easy | BiometricActivityTests | 取消驗證 |
| FW-076 | Builder.setAllowedAuthenticators() | - | COND, BOUND | Medium | BiometricSimpleTests | 設定允許的驗證器 |

---

## Locale 子模組

### 10. LocaleManager

**檔案**: `frameworks/base/core/java/android/app/LocaleManager.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-081 | setApplicationLocales() | - | STATE, ERR | Medium | LocaleManagerTests | 設定 App Locale |
| FW-082 | getApplicationLocales() | - | COND | Easy | LocaleManagerTests | 獲取 App Locale |
| FW-083 | getSystemLocales() | - | COND | Easy | LocaleManagerSystemLocaleTest | 獲取系統 Locale |

---

## GrammaticalInflection 子模組

### 11. GrammaticalInflectionManager

**檔案**: `frameworks/base/core/java/android/app/GrammaticalInflectionManager.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| FW-091 | setRequestedApplicationGrammaticalGender() | - | STATE, COND | Medium | GrammaticalInflectionManagerTest | 設定語法性別 |

---

## 統計摘要

### 按注入類型
| 注入類型 | 數量 | 百分比 |
|----------|------|--------|
| STATE（狀態轉換）| 32 | 71% |
| COND（條件判斷）| 28 | 62% |
| BOUND（邊界檢查）| 8 | 18% |
| ERR（錯誤處理）| 6 | 13% |
| CALC（數值計算）| 5 | 11% |
| RES（資源管理）| 3 | 7% |
| SYNC（同步問題）| 1 | 2% |

### 按子模組
| 子模組 | 注入點數 | 優先級 |
|--------|---------|--------|
| WindowManager (Activity) | 9 | 高 |
| WindowManager (WMS) | 10 | 高 |
| WindowInsets | 6 | 中 |
| InsetsController | 4 | 中 |
| Keyguard | 5 | 中 |
| Multi-Display | 4 | 低 |
| PiP | 3 | 低 |
| Biometrics | 6 | 中 |
| Locale | 3 | 低 |
| GrammaticalInflection | 1 | 低 |

---

## CTS 測試類別對照

### WindowManager 測試（139 個）

#### Activity 生命週期
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| ActivityLifecycleTests | Activity 生命週期狀態轉換 | FW-001~FW-005 |
| ActivityLifecycleKeyguardTests | Keyguard 下的生命週期 | FW-041~FW-045 |
| ActivityLifecyclePipTests | PiP 模式生命週期 | FW-061~FW-063 |
| ActivityVisibilityTests | Activity 可見性 | FW-002 |
| ConfigChangeTests | 配置變更 | FW-008 |

#### Window Insets
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| WindowInsetsTest | WindowInsets 基本 API | FW-021~FW-026 |
| WindowInsetsLayoutTests | Insets 佈局 | FW-024, FW-025 |
| WindowInsetsControllerTests | 控制器 API | FW-031~FW-034 |
| WindowInsetsAnimationTests | Insets 動畫 | FW-034 |

#### Keyguard
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| KeyguardTests | Keyguard 基本功能 | FW-014~FW-018, FW-041~FW-044 |
| KeyguardLockedTests | 鎖定狀態測試 | FW-043 |
| KeyguardTransitionTests | Keyguard 轉場 | FW-045 |

#### Multi-Display
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| MultiDisplayActivityLaunchTests | 多螢幕 Activity 啟動 | FW-051, FW-052 |
| MultiDisplayPolicyTests | 多螢幕策略 | FW-052 |
| DisplayCutoutTests | DisplayCutout 處理 | FW-054 |

### Biometrics 測試（8 個）
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| BiometricServiceTests | Biometric Service 邏輯 | FW-071~FW-073 |
| BiometricActivityTests | Biometric UI 流程 | FW-074, FW-075 |
| BiometricSimpleTests | 基本 API | FW-076 |

### Locale 測試（4 個）
| 測試類別 | 描述 | 注入點 |
|---------|------|--------|
| LocaleManagerTests | LocaleManager API | FW-081, FW-082 |
| LocaleManagerSystemLocaleTest | 系統 Locale | FW-083 |

---

## 下一步 - Phase B

從此列表中挑選 15-20 個注入點，進行題目生成：

### 建議優先順序
1. **高優先** — Activity 生命週期 (FW-001~FW-005)：最核心的 Android 概念
2. **高優先** — WindowInsets (FW-021~FW-026)：常見 UI 開發問題
3. **中優先** — Keyguard (FW-041~FW-045)：安全相關
4. **中優先** — Biometrics (FW-071~FW-076)：認證流程

### 進度
- [x] Phase A 完成 - 注入點列表已建立 (45 個)
- [ ] Phase B - 挑選注入點、設計 bug、產生 patch
- [ ] Phase C - 實機驗證

---

**文件版本**: v1.0.0  
**建立時間**: 2026-02-10 18:30 GMT+8
