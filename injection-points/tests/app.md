# App 模組注入點分布列表

**CTS 路徑**: `cts/tests/app/`  
**更新時間**: 2025-06-27 19:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 52 |
| Easy | 18 (35%) |
| Medium | 22 (42%) |
| Hard | 12 (23%) |

**涵蓋測試類別**：Activity、Service、BroadcastReceiver、PendingIntent、Dialog、Fragment、Instrumentation、系統管理器

## CTS 測試類別

### Activity 相關測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| ActivityManagerTest | ActivityManager 各種 API | 高 |
| LifecycleTest | Activity 生命週期 | 高 |
| ActivityCallbacksTest | Activity 回調 | 中 |
| ActivityOptionsTest | Activity 啟動選項 | 中 |
| ActivityGroupTest | ActivityGroup | 低 |
| LocalActivityManagerTest | 嵌套 Activity 管理 | 低 |
| NewDocumentTest | 多文檔支援 | 中 |
| TaskDescriptionTest | 任務描述 | 中 |

### Service 相關測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| ServiceTest | Service 生命週期、綁定 | 高 |
| IntentServiceTest | IntentService | 中 |
| FgsTest | 前台服務類型 | 高 |
| FgsStartTest | 前台服務啟動 | 高 |
| ShortFgsTest | 短時前台服務 | 中 |
| ActivityManagerFgsBgStartTest | 後台啟動前台服務 | 高 |
| ActivityManagerFgsDelegateTest | 前台服務委託 | 中 |

### Broadcast 相關測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| BroadcastOptionsTest | 廣播選項 | 高 |
| BroadcastsTest | 廣播傳遞 | 高 |
| BroadcastDeferralTest | 廣播延遲 | 中 |
| BroadcastDeliveryGroupTest | 廣播分組 | 中 |

### PendingIntent 測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| PendingIntentTest | PendingIntent 創建與發送 | 高 |

### Dialog 相關測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| AlertDialogTest | AlertDialog | 中 |
| DialogTest | Dialog 基類 | 中 |
| ProgressDialogTest | ProgressDialog | 低 |
| TimePickerDialogTest | TimePickerDialog | 低 |

### Fragment 相關測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| FragmentTest | Fragment 生命週期 | 高 |
| FragmentTransactionTest | Fragment 事務 | 高 |
| FragmentReceiveResultTest | Fragment 結果接收 | 中 |

### Instrumentation 測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| InstrumentationTest | Instrumentation 框架 | 中 |
| Instrumentation_ActivityMonitorTest | Activity 監控 | 中 |

### 系統服務測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| KeyguardManagerTest | 鎖屏管理 | 中 |
| UiModeManagerTest | UI 模式 | 中 |
| StatusBarManagerTest | 狀態欄 | 低 |
| DownloadManagerTest | 下載管理 | 中 |
| SearchManagerTest | 搜索 | 低 |
| SystemFeaturesTest | 系統特性 | 低 |

### 其他測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| ApplicationTest | Application 類 | 中 |
| BackupAgentTest | 備份代理 | 低 |
| AppExitInfoTest | 應用退出信息 | 中 |

## 對應 AOSP 源碼路徑

### Java 層（Framework）
- `frameworks/base/core/java/android/app/` — App Framework 核心
  - `Activity.java` (9840 行) ⭐ Activity 核心實現
  - `ActivityManager.java` (6234 行) ⭐ 進程和任務管理
  - `Service.java` (1199 行) ⭐ Service 核心實現
  - `PendingIntent.java` (1611 行) ⭐ PendingIntent 實現
  - `BroadcastOptions.java` (1243 行) — 廣播選項
  - `Dialog.java` (1512 行) — 對話框基類
  - `AlertDialog.java` (1136 行) — 警告對話框
  - `Fragment.java` (2989 行) — Fragment 核心
  - `FragmentManager.java` (3741 行) — Fragment 管理
  - `Instrumentation.java` (2687 行) — 測試框架
  - `KeyguardManager.java` (1374 行) — 鎖屏管理
  - `DownloadManager.java` (1848 行) — 下載管理
  - `NotificationManager.java` (2998 行) — 通知管理
  - `UiModeManager.java` (1411 行) — UI 模式
  - `StatusBarManager.java` (1654 行) — 狀態欄管理
  - `ActivityOptions.java` (112861 行) — 啟動選項
  - `ActivityThread.java` (388974 行) — 主執行緒管理

---

## 注入點清單

### 1. Activity（核心生命週期）⭐

**檔案**: `frameworks/base/core/java/android/app/Activity.java` (9840 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-001 | onCreate() | 1794-1830 | STATE, COND | Medium | LifecycleTest | 創建邏輯：savedInstanceState 處理、Fragment 恢復 |
| APP-002 | onStart() | 2081-2110 | STATE | Easy | LifecycleTest | 啟動邏輯：dispatchStart |
| APP-003 | onResume() | 2159-2190 | STATE | Easy | LifecycleTest | 恢復邏輯：mCalled 檢查 |
| APP-004 | onPause() | 2586-2620 | STATE | Easy | LifecycleTest | 暫停邏輯 |
| APP-005 | onStop() | 2815-2850 | STATE, RES | Medium | LifecycleTest | 停止邏輯：Fragment 處理 |
| APP-006 | onDestroy() | 2859-2900 | STATE, RES | Medium | LifecycleTest | 銷毀邏輯：資源釋放 |
| APP-007 | finish() | 7291-7310 | COND, STATE | Easy | ActivityManagerTest | 結束 Activity |
| APP-008 | finishAffinity() | 7309-7330 | COND, ERR | Medium | ActivityManagerTest | 結束親和性 Activity，異常檢查 |
| APP-009 | onActivityResult() | 7433-7440 | COND | Easy | FragmentReceiveResultTest | 結果回調 |
| APP-010 | startActivityForResult() | 5797-5840 | COND, ERR | Medium | ActivityManagerTest | 啟動並等待結果 |
| APP-011 | onRestoreInstanceState() | 1920-1940 | COND, STATE | Medium | LifecycleTest | 狀態恢復 |
| APP-012 | onSaveInstanceState() | 2400-2450 | STATE | Medium | LifecycleTest | 狀態保存 |

### 2. ActivityManager（進程管理）⭐

**檔案**: `frameworks/base/core/java/android/app/ActivityManager.java` (6234 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-021 | getRunningTasks() | 2898-2920 | COND | Easy | ActivityManagerTest | 獲取運行中任務 |
| APP-022 | getRunningServices() | 3169-3190 | COND | Easy | ActivityManager_RunningServiceInfoTest | 獲取運行中服務 |
| APP-023 | getRunningAppProcesses() | 4030-4050 | COND | Easy | ActivityManager_RunningAppProcessInfoTest | 獲取運行中進程 |
| APP-024 | getMemoryClass() | 1470-1490 | CALC | Easy | ActivityManagerMemoryClassTest | 獲取內存級別 |
| APP-025 | isLowRamDevice() | 1517-1530 | COND | Easy | ActivityManagerMemoryInfoTest | 判斷低內存設備 |
| APP-026 | killBackgroundProcesses() | 4619-4640 | ERR | Medium | ActivityManagerTest | 殺死後台進程 |
| APP-027 | forceStopPackage() | 4680-4700 | ERR | Medium | ForceStopTest | 強制停止應用 |
| APP-028 | getMyMemoryState() | 4559-4580 | STATE | Medium | ActivityManagerProcessStateTest | 獲取自身內存狀態 |
| APP-029 | isUserAMonkey() | 4822-4830 | COND | Easy | ActivityManagerTest | 判斷是否為 monkey 測試 |
| APP-030 | getDeviceConfigurationInfo() | 4731-4750 | COND | Easy | SystemFeaturesTest | 獲取設備配置 |

### 3. Service（服務生命週期）⭐

**檔案**: `frameworks/base/core/java/android/app/Service.java` (1199 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-031 | onCreate() | 366-380 | STATE | Easy | ServiceTest | 服務創建 |
| APP-032 | onStartCommand() | 500-530 | COND, STATE | Medium | ServiceTest | 啟動命令處理，返回值影響重啟行為 |
| APP-033 | onBind() | 560-580 | COND | Easy | ServiceTest | 綁定處理 |
| APP-034 | onUnbind() | 586-600 | COND | Easy | ServiceTest | 解綁處理，返回值影響 rebind |
| APP-035 | onRebind() | 601-620 | STATE | Easy | ServiceTest | 重新綁定 |
| APP-036 | onDestroy() | 537-550 | STATE, RES | Medium | ServiceTest | 服務銷毀，資源釋放 |
| APP-037 | startForeground() | 770-790 | COND, ERR | Hard | FgsTest | 前台服務，id 不能為 0 |
| APP-038 | stopForeground() | 900-920 | COND | Medium | FgsTest | 停止前台服務 |
| APP-039 | stopSelf() | 623-630 | STATE | Easy | ServiceTest | 停止自身 |
| APP-040 | stopSelf(int) | 632-650 | COND | Medium | ServiceTest | 條件停止，startId 檢查 |
| APP-041 | getForegroundServiceType() | 940-960 | COND | Easy | FgsTest | 獲取前台服務類型 |
| APP-042 | onTimeout() | 1130-1150 | COND | Medium | ShortFgsTest | 短時 FGS 超時回調 |

### 4. PendingIntent ⭐

**檔案**: `frameworks/base/core/java/android/app/PendingIntent.java` (1611 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-051 | getActivity() | 525-570 | COND, ERR | Medium | PendingIntentTest | 創建 Activity PI，FLAG 驗證 |
| APP-052 | getBroadcast() | 749-760 | COND, ERR | Medium | PendingIntentTest | 創建 Broadcast PI |
| APP-053 | getService() | 803-830 | COND, ERR | Medium | PendingIntentTest | 創建 Service PI |
| APP-054 | send() | 890-950 | ERR | Medium | PendingIntentTest | 發送 PI，CanceledException |
| APP-055 | cancel() | 873-890 | STATE | Easy | PendingIntentTest | 取消 PI |
| APP-056 | getCreatorPackage() | 1200-1220 | COND | Easy | PendingIntentTest | 獲取創建者包名 |
| APP-057 | getCreatorUid() | 1230-1250 | COND | Easy | PendingIntentTest | 獲取創建者 UID |

### 5. BroadcastOptions

**檔案**: `frameworks/base/core/java/android/app/BroadcastOptions.java` (1243 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-061 | setTemporaryAppAllowlist() | 423-440 | COND, BOUND | Hard | BroadcastOptionsTest | 臨時白名單，duration/type 驗證 |
| APP-062 | setDontSendToRestrictedApps() | 563-575 | COND | Easy | BroadcastOptionsTest | 限制應用過濾 |
| APP-063 | setBackgroundActivityStartsAllowed() | 586-600 | COND | Medium | BroadcastOptionsTest | 後台啟動控制 |
| APP-064 | setRequireAllOfPermissions() | 618-640 | COND, BOUND | Medium | BroadcastOptionsTest | 權限要求 |
| APP-065 | setDeliveryGroupPolicy() | 680-720 | COND | Medium | BroadcastDeliveryGroupTest | 傳遞群組策略 |

### 6. Dialog（對話框）

**檔案**: `frameworks/base/core/java/android/app/Dialog.java` (1512 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-071 | show() | 311-370 | STATE, COND | Medium | DialogTest | 顯示邏輯：mShowing 檢查、onCreate 調用 |
| APP-072 | dismiss() | 379-400 | STATE, SYNC | Medium | DialogTest | 關閉邏輯：執行緒安全處理 |
| APP-073 | dismissDialog() | 393-420 | COND, RES | Medium | DialogTest | 內部關閉：mDecor/mShowing 檢查 |
| APP-074 | onCreate() | 449-450 | STATE | Easy | DialogTest | 創建回調 |
| APP-075 | onStart() | 458-470 | STATE | Easy | DialogTest | 啟動回調 |
| APP-076 | onStop() | 475-490 | STATE | Easy | DialogTest | 停止回調 |
| APP-077 | cancel() | 1347-1360 | STATE, COND | Easy | DialogTest | 取消對話框 |

### 7. Fragment（片段）

**檔案**: `frameworks/base/core/java/android/app/Fragment.java` (2989 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-081 | onAttach() | 1461-1480 | STATE | Easy | FragmentTest | 附加到 Activity |
| APP-082 | onCreate() | 1508-1530 | STATE, COND | Medium | FragmentTest | Fragment 創建，savedInstanceState |
| APP-083 | onCreateView() | 1540-1560 | COND | Medium | FragmentTest | 創建視圖 |
| APP-084 | onViewCreated() | 1570-1580 | STATE | Easy | FragmentTest | 視圖創建完成 |
| APP-085 | onStart() | 1624-1640 | STATE | Easy | FragmentTest | Fragment 啟動 |
| APP-086 | onResume() | 1645-1660 | STATE | Easy | FragmentTest | Fragment 恢復 |
| APP-087 | onPause() | 1737-1745 | STATE | Easy | FragmentTest | Fragment 暫停 |
| APP-088 | onStop() | 1747-1760 | STATE | Easy | FragmentTest | Fragment 停止 |
| APP-089 | onDestroyView() | 1771-1780 | STATE, RES | Medium | FragmentTest | 銷毀視圖 |
| APP-090 | onDestroy() | 1780-1800 | STATE, RES | Medium | FragmentTest | Fragment 銷毀 |
| APP-091 | onDetach() | 1829-1845 | STATE | Easy | FragmentTest | 從 Activity 分離 |

### 8. Instrumentation（測試框架）

**檔案**: `frameworks/base/core/java/android/app/Instrumentation.java` (2687 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-101 | startActivitySync() | 1500-1550 | SYNC, ERR | Hard | InstrumentationTest | 同步啟動 Activity，超時處理 |
| APP-102 | callActivityOnCreate() | 1300-1350 | STATE | Medium | InstrumentationTest | 調用 Activity.onCreate |
| APP-103 | callActivityOnDestroy() | 1400-1420 | STATE | Medium | InstrumentationTest | 調用 Activity.onDestroy |
| APP-104 | addMonitor() | 1100-1130 | SYNC | Medium | Instrumentation_ActivityMonitorTest | 添加 Activity 監控 |
| APP-105 | removeMonitor() | 1140-1160 | SYNC | Easy | Instrumentation_ActivityMonitorTest | 移除監控 |
| APP-106 | waitForMonitor() | 1170-1200 | SYNC | Hard | Instrumentation_ActivityMonitorTest | 等待監控，超時邏輯 |
| APP-107 | sendKeyDownUpSync() | 900-950 | SYNC | Medium | InstrumentationTest | 同步發送按鍵 |

### 9. KeyguardManager（鎖屏管理）

**檔案**: `frameworks/base/core/java/android/app/KeyguardManager.java` (1374 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-111 | isKeyguardLocked() | 600-620 | COND | Easy | KeyguardManagerTest | 判斷鎖屏狀態 |
| APP-112 | isKeyguardSecure() | 630-650 | COND | Easy | KeyguardManagerStatusTest | 判斷安全鎖屏 |
| APP-113 | isDeviceLocked() | 660-680 | COND | Easy | KeyguardManagerTest | 判斷設備鎖定 |
| APP-114 | isDeviceSecure() | 690-710 | COND | Easy | KeyguardManagerTest | 判斷設備安全 |
| APP-115 | requestDismissKeyguard() | 800-850 | ERR | Hard | KeyguardManagerKeyguardLockTest | 請求關閉鎖屏，回調處理 |

### 10. UiModeManager（UI 模式）

**檔案**: `frameworks/base/core/java/android/app/UiModeManager.java` (1411 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| APP-121 | getCurrentModeType() | 400-420 | COND | Easy | UiModeManagerTest | 獲取當前模式類型 |
| APP-122 | setNightMode() | 500-530 | COND | Medium | UiModeManagerTest | 設置夜間模式 |
| APP-123 | getNightMode() | 540-560 | COND | Easy | UiModeManagerTest | 獲取夜間模式 |
| APP-124 | setApplicationNightMode() | 600-630 | COND | Medium | UiModeManagerTest | 設置應用夜間模式 |

---

## 統計摘要

| 注入類型 | 數量 | 說明 |
|----------|------|------|
| STATE（狀態轉換）| 35 | 生命週期、狀態機 |
| COND（條件判斷）| 42 | if/else、switch、比較 |
| ERR（錯誤處理）| 12 | 異常、回傳值檢查 |
| RES（資源管理）| 8 | 資源釋放 |
| SYNC（同步問題）| 6 | 執行緒安全、等待 |
| BOUND（邊界檢查）| 3 | 陣列索引、範圍驗證 |
| CALC（數值計算）| 1 | 計算邏輯 |

## 重點注入區域（推薦優先出題）

### 高優先級（12 個）
| ID | 組件 | 函數 | 原因 |
|----|------|------|------|
| APP-001 | Activity | onCreate() | 核心生命週期，savedInstanceState 邏輯 |
| APP-037 | Service | startForeground() | 前台服務核心，id != 0 檢查 |
| APP-054 | PendingIntent | send() | 異常處理，CanceledException |
| APP-051 | PendingIntent | getActivity() | FLAG_IMMUTABLE/MUTABLE 驗證 |
| APP-071 | Dialog | show() | 多重狀態檢查 |
| APP-061 | BroadcastOptions | setTemporaryAppAllowlist() | 複雜參數驗證 |
| APP-082 | Fragment | onCreate() | Fragment 生命週期核心 |
| APP-032 | Service | onStartCommand() | 返回值決定重啟行為 |
| APP-101 | Instrumentation | startActivitySync() | 同步超時處理 |
| APP-106 | Instrumentation | waitForMonitor() | 超時等待邏輯 |
| APP-008 | Activity | finishAffinity() | 異常條件檢查 |
| APP-115 | KeyguardManager | requestDismissKeyguard() | 回調處理 |

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證

---

**版本**: v1.0.0  
**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/app.md`
