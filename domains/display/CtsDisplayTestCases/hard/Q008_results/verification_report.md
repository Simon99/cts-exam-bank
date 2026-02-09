# Q008 CTS 驗證報告

**驗證日期:** 2025-02-09 (完整驗證)  
**驗證設備:** 2B231FDH200B4Z (Pixel 7)  
**基準 Image:** ~/aosp-images/clean-panther-14/ (eng.simon.20250805.233538)

## 驗證結果: ❌ DESIGN ISSUE

### 問題 1: Bug Patch 無效
Q008_bug.patch 只添加註釋，沒有改變代碼行為：
```diff
+            // BUG: The following synchronization code was removed during a refactor.
+            // This causes Display.getState() to return stale values while
+            // callbacks are correctly dispatched. The mIsDisplayOn flag and mInfo
+            // cache should be updated here but aren't, causing state inconsistency.
+            // Missing: setDisplayState(state != Display.STATE_OFF);
```
這些只是註釋，不會引入任何可測試的 bug。

### 問題 2: 測試方法不存在
Q008 問題描述中提到的測試：
```
android.display.cts.VirtualDisplayTest#testVirtualDisplayStateConsistency
```
**不存在於實際 CTS 測試中。**

實際存在的 VirtualDisplayTest 方法：
- testGetHdrCapabilitiesWithUserDisabledFormats
- testHdrApiMethods
- testPrivatePresentationVirtualDisplay
- testPrivateVirtualDisplay
- testPrivateVirtualDisplayWithDynamicSurface
- testTrustedVirtualDisplay
- testUntrustedSysDecorVirtualDisplay
- testVirtualDisplayDoesNotRotateWithContent
- testVirtualDisplayRotatesWithContent
- testVirtualDisplayWithRequestedRefreshRate

### 問題 3: 現有測試全通過
在乾淨 image 上運行：
```
adb shell am instrument -w -e class android.display.cts.VirtualDisplayTest \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```
結果：**OK (10 tests)** — 全部通過

## 代碼分析

### 原代碼狀態
`VirtualDisplayAdapter.java` 中的 `requestDisplayStateLocked()`:
```java
public Runnable requestDisplayStateLocked(int state, ...) {
    if (state != mDisplayState) {
        mDisplayState = state;
        if (state == Display.STATE_OFF) {
            mCallback.dispatchDisplayPaused();
        } else {
            mCallback.dispatchDisplayResumed();
        }
    }
    return null;
}
```

確實沒有調用 `setDisplayState()` 來同步 `mIsDisplayOn`，但這在現有 CTS 測試中不會導致失敗。

### Fix Patch 分析
Q008_fix.patch 添加了同步邏輯：
```java
boolean isOn = (state != Display.STATE_OFF 
        && state != Display.STATE_DOZE_SUSPEND);
if (mIsDisplayOn != isOn) {
    mIsDisplayOn = isOn;
    mInfo = null;
    sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
}
```

這是合理的改進，但現有測試無法驗證其效果。

## 建議修改

### 選項 A: 創建真正的 Bug Patch
修改 `setDisplayState()` 讓它永遠不更新：
```diff
void setDisplayState(boolean isOn) {
-    if (mIsDisplayOn != isOn) {
-        mIsDisplayOn = isOn;
-        mInfo = null;
-        sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
-    }
+    // BUG: Disabled state synchronization
+    // if (mIsDisplayOn != isOn) { ... }
}
```

### 選項 B: 創建自定義測試 APK
添加實際的 `testVirtualDisplayStateConsistency` 測試方法。

### 選項 C: 標記為純理論題
將 Q008 改為「分析類」題目，不需要實機驗證。

## 結論

Q008 設計需要修改才能成為可驗證的面試題。目前狀態：
- Bug patch: ❌ 無效（只有註釋）
- CTS 測試: ❌ 不存在
- 驗證可行性: ❌ 無法驗證

**建議:** 標記為 NEEDS_REDESIGN 或採用選項 A 創建有效 bug patch
