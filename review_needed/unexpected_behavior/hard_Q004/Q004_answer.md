# Q004 答案：Virtual Display Resize 事件丟失

## 問題根因

在 `LogicalDisplayMapper.updateLogicalDisplaysLocked()` 方法中，用於比較 DisplayInfo 變化的操作順序錯誤。

### Bug 代碼（錯誤順序）

```java
// LogicalDisplayMapper.java, updateLogicalDisplaysLocked 方法
display.updateLocked(mDisplayDeviceRepo);           // ❌ 先更新
boolean wasDirty = display.isDirtyLocked();         // wasDirty = false (已被清除)
mTempDisplayInfo.copyFrom(display.getDisplayInfoLocked()); // 複製的是「新」狀態
display.getNonOverrideDisplayInfoLocked(mTempNonOverrideDisplayInfo);
final DisplayInfo newDisplayInfo = display.getDisplayInfoLocked(); // 也是「新」狀態
// mTempDisplayInfo == newDisplayInfo，比較結果為「沒變化」
```

### 修復代碼（正確順序）

```java
// 必須在 updateLocked 之前捕獲狀態，才能檢測變化
boolean wasDirty = display.isDirtyLocked();         // 捕獲 dirty 標記
mTempDisplayInfo.copyFrom(display.getDisplayInfoLocked()); // 保存「舊」狀態
display.getNonOverrideDisplayInfoLocked(mTempNonOverrideDisplayInfo);

display.updateLocked(mDisplayDeviceRepo);           // 更新 display
final DisplayInfo newDisplayInfo = display.getDisplayInfoLocked(); // 獲取「新」狀態
// 現在可以正確比較 mTempDisplayInfo（舊）和 newDisplayInfo（新）
```

## 多檔案交互分析

### 事件傳播路徑

```
VirtualDisplayAdapter.resizeLocked()
    ↓ sendDisplayDeviceEventLocked(DISPLAY_DEVICE_EVENT_CHANGED)
DisplayDeviceRepository.onDisplayDeviceEvent()
    ↓ 
LogicalDisplayMapper.onDisplayDeviceChangedLocked()
    ↓
LogicalDisplayMapper.updateLogicalDisplaysLocked()  ← Bug 在這裡
    ↓ mListener.onLogicalDisplayEventLocked(LOGICAL_DISPLAY_EVENT_CHANGED)
DisplayManagerService.handleLogicalDisplayChangedLocked()
    ↓ sendDisplayEventIfEnabledLocked(EVENT_DISPLAY_CHANGED)
CallbackRecord.notifyDisplayEventAsync()
    ↓
App's DisplayListener.onDisplayChanged()  ← 永遠不會被觸發
```

### 涉及的檔案

1. **VirtualDisplayAdapter.java** (第 419-428 行)
   - 觸發變更：`resizeLocked()` 更新 width/height/densityDpi
   - 發送事件：`sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED)`

2. **DisplayDeviceRepository.java**
   - 轉發事件給 LogicalDisplayMapper

3. **LogicalDisplayMapper.java** (第 716-789 行) - **核心問題**
   - 比較 DisplayInfo 變化
   - 錯誤的順序導致新舊狀態相同

4. **LogicalDisplay.java** (第 382-524 行)
   - `updateLocked()` 更新 mBaseDisplayInfo 並清除 mDirty
   - `getDisplayInfoLocked()` 返回當前 DisplayInfo

5. **DisplayManagerService.java** (第 3510-3533 行)
   - 接收 LOGICAL_DISPLAY_EVENT_CHANGED
   - 調用 `handleLogicalDisplayChangedLocked()` 發送事件到 callbacks

## 修復方案

```diff
--- a/services/core/java/com/android/server/display/LogicalDisplayMapper.java
+++ b/services/core/java/com/android/server/display/LogicalDisplayMapper.java
@@ -716,10 +716,11 @@ class LogicalDisplayMapper implements DisplayDeviceRepository.Listener {
             LogicalDisplay display = mLogicalDisplays.valueAt(i);
             assignDisplayGroupLocked(display);
 
-            display.updateLocked(mDisplayDeviceRepo);
+            // Must capture state BEFORE updateLocked to detect changes
             boolean wasDirty = display.isDirtyLocked();
             mTempDisplayInfo.copyFrom(display.getDisplayInfoLocked());
             display.getNonOverrideDisplayInfoLocked(mTempNonOverrideDisplayInfo);
+
+            display.updateLocked(mDisplayDeviceRepo);
             final DisplayInfo newDisplayInfo = display.getDisplayInfoLocked();
```

## 驗證方式

```bash
# 執行 CTS 測試
adb shell am instrument -w -r \
  -e class android.display.cts.DisplayEventTest \
  android.display.cts/androidx.test.runner.AndroidJUnitRunner

# 預期結果：測試通過
# testDisplayEvents 應該能夠正確接收 DISPLAY_CHANGED 事件
```

## 學習要點

1. **狀態比較的順序至關重要**：要檢測變化，必須在修改前保存原始狀態
2. **多檔案追蹤**：Display 事件傳播涉及 5+ 個檔案，需要理解完整的調用鏈
3. **理解 dirty 標記**：mDirty 在 updateLocked 中被清除，所以必須先讀取
4. **異步事件處理**：sendDisplayDeviceEventLocked 是異步的，但狀態比較是同步的
