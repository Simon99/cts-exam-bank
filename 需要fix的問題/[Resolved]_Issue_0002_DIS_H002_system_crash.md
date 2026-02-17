# Issue 0002: DIS-H002 Bug 導致系統無法啟動

## 基本資訊
- **題目 ID**: DIS-H002 (display/hard/Q002)
- **發現日期**: 2026-02-11
- **嚴重程度**: Critical（系統崩潰）

## 問題描述

Bug patch 套用後，系統無法正常運行：
- PackageManager 服務未啟動（`Can't find service: package`）
- CTS 測試無法安裝 APK
- 設備處於不穩定狀態

## Bug Patch 內容

```java
// 原始
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
    deviceInfo.supportedModes, deviceInfo.supportedModes.length);

// Bug（當 mDirty=true 時截斷陣列）
int modeCount = deviceInfo.supportedModes.length;
if (mDirty && modeCount > 1) {
    modeCount = modeCount - 1;  // 少複製一個 mode
}
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
    deviceInfo.supportedModes, modeCount);
```

## 問題分析

Bug 設計不當：
- `mDirty` 在系統啟動時會是 true
- 這導致 supportedModes 陣列被截斷
- 可能導致 Display 子系統初始化失敗
- 連鎖反應導致 PackageManager 等核心服務無法啟動

## 建議修復方案

### 方案 A：修改 Bug 觸發條件
讓 bug 只在特定操作（如 mode 切換）時觸發，而不是系統啟動時：
```java
// 只在有 pending mode transition 時觸發
if (mPendingModeTransition && modeCount > 1) {
    ...
}
```

### 方案 B：重新設計題目
選擇一個不會導致系統崩潰的 bug 類型

## 相關檔案
- Bug Patch: `domains/display/hard/Q002_bug.patch`
- 修改檔案: `LogicalDisplay.java`

## 狀態
- [ ] 待修復

---

## 嘗試記錄

### 1st Trial (2026-02-11)

**修改方向**：改用 `mInfo.get() != null` 作為觸發條件

**設計思路**：
- 假設 `mInfo.get()` 只在 client 查詢後才會是 non-null
- 系統第一次初始化時不會觸發截斷
- 後續 display 更新時才會截斷 supportedModes

**實際 Patch**：
```java
int modeCount = deviceInfo.supportedModes.length;
if (mInfo.get() != null && modeCount > 1) {
    // After first query, only keep first mode
    modeCount = 1;
}
mBaseDisplayInfo.supportedModes = Arrays.copyOf(
        deviceInfo.supportedModes, modeCount);
```

**結果**：❌ 仍然導致系統崩潰

**失敗原因**：
- `mInfo.get()` 在系統內部啟動流程中就會被設置
- 錯誤發生在 `DisplayManagerService.getDisplayInfoForFrameRateOverride`
- 崩潰時序：系統啟動 → DisplayManager 內部查詢 → `mInfo` 被設置 → display 更新 → 截斷觸發 → 崩潰

**Logcat 錯誤**：
```
E Zygote  : at com.android.server.display.DisplayManagerService.getDisplayInfoForFrameRateOverride(DisplayManagerService.java:1113)
E Zygote  : at com.android.server.display.DisplayManagerService.getDisplayInfoInternal(DisplayManagerService.java:1165)
...
E Zygote  : at com.android.server.SystemServer.startBootstrapServices(SystemServer.java:1289)
```

**教訓**：
- 不能假設任何內部狀態（`mDirty`、`mInfo`）只在 client 查詢後才改變
- 系統內部在啟動過程中會進行大量的 display 資訊查詢
- 需要找一個真正只在 CTS 測試時才會觸發的條件，或者選擇完全不同的 bug 設計方向
