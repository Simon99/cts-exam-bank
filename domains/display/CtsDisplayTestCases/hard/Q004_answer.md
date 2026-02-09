# Q004 答案：Virtual Display Resize 事件丟失 - 條件邏輯錯誤

## 問題根因

在 `LogicalDisplayMapper.updateLogicalDisplaysLocked()` 方法中，檢測 DisplayInfo 變化的布林條件使用了錯誤的邏輯運算符。

### Bug 代碼（邏輯錯誤）

```java
// LogicalDisplayMapper.java, 第 781 行
// ❌ 錯誤：使用 && 導致需要兩個條件都為真才會發送事件
} else if (wasDirty && !mTempDisplayInfo.equals(newDisplayInfo)) {
    mLogicalDisplaysToUpdate.put(displayId, LOGICAL_DISPLAY_EVENT_CHANGED);
}
```

### 修復代碼（正確邏輯）

```java
// ✅ 正確：使用 || 只要任一條件為真就發送事件
} else if (wasDirty || !mTempDisplayInfo.equals(newDisplayInfo)) {
    mLogicalDisplaysToUpdate.put(displayId, LOGICAL_DISPLAY_EVENT_CHANGED);
}
```

## 邏輯分析

### 為什麼 && 會導致問題？

1. **wasDirty 的狀態**：
   - `mDirty` 在 LogicalDisplay 構造時設為 `true`
   - 第一次 `updateLocked()` 完成後設為 `false`
   - VirtualDisplay.resize() 不會重新設置 `mDirty = true`
   - 因此在 resize 操作時：`wasDirty = false`

2. **DisplayInfo 比較**：
   - `mTempDisplayInfo` 在 `updateLocked()` 之前保存舊狀態
   - `newDisplayInfo` 在 `updateLocked()` 之後獲取新狀態
   - resize 改變了 density，所以：`!mTempDisplayInfo.equals(newDisplayInfo) = true`

3. **條件評估**：
   - **原始 (||)**：`false || true = true` → 發送 DISPLAY_CHANGED 事件 ✓
   - **Bug (&&)**：`false && true = false` → 不發送事件 ✗

### 邏輯語義的差異

| 運算符 | 語義 | 適用場景 |
|--------|------|----------|
| `\|\|` | 任一條件成立就觸發 | ✅ 正確：dirty OR changed 任一為真都應發送事件 |
| `&&` | 兩個條件都成立才觸發 | ❌ 錯誤：要求 dirty AND changed 同時為真 |

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

1. **LogicalDisplayMapper.java** (第 778-790 行) - **核心問題**
   - 布林條件 `wasDirty || !mTempDisplayInfo.equals(newDisplayInfo)`
   - 錯誤地使用 `&&` 導致事件不發送

2. **LogicalDisplay.java** (第 180, 331-332, 400-524 行)
   - `mDirty` 標記的定義和管理
   - `isDirtyLocked()` 返回當前 dirty 狀態
   - `updateLocked()` 更新 DisplayInfo 並清除 mDirty

3. **VirtualDisplayAdapter.java** (第 419-428 行)
   - 觸發變更：`resizeLocked()` 更新 width/height/densityDpi
   - 發送事件：`sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED)`

4. **DisplayManagerService.java** (第 3510-3533 行)
   - 接收 LOGICAL_DISPLAY_EVENT_CHANGED
   - 調用 `handleLogicalDisplayChangedLocked()` 發送事件到 callbacks

## 修復方案

```diff
--- a/services/core/java/com/android/server/display/LogicalDisplayMapper.java
+++ b/services/core/java/com/android/server/display/LogicalDisplayMapper.java
@@ -778,7 +778,7 @@ class LogicalDisplayMapper implements DisplayDeviceRepository.Listener {
                 int event = isCurrentlyEnabled ? LOGICAL_DISPLAY_EVENT_ADDED :
                         LOGICAL_DISPLAY_EVENT_REMOVED;
                 mLogicalDisplaysToUpdate.put(displayId, event);
-            } else if (wasDirty && !mTempDisplayInfo.equals(newDisplayInfo)) {
+            } else if (wasDirty || !mTempDisplayInfo.equals(newDisplayInfo)) {
                 // If only the hdr/sdr ratio changed, then send just the event for that case
                 if ((diff == DisplayDeviceInfo.DIFF_HDR_SDR_RATIO)) {
                     mLogicalDisplaysToUpdate.put(displayId,
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

1. **布林邏輯的重要性**：`||` 和 `&&` 的語義完全不同，拼寫錯誤可能導致嚴重問題
2. **Short-circuit evaluation**：`&&` 在第一個條件為 false 時就返回 false，不會評估第二個條件
3. **理解 dirty 標記**：mDirty 在 updateLocked 中被清除，通常在事件處理時為 false
4. **防禦性編程**：重要的條件判斷應該有單元測試覆蓋

## 常見錯誤模式

這種錯誤在真實代碼中很常見，原因包括：
- 快速打字時 `||` 誤寫成 `&&`
- Copy-paste 後修改不完整
- 對邏輯語義理解不清楚
- 代碼審查時容易忽略
