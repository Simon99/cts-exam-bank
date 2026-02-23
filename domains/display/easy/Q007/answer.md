# 答案 - Display Type 設置錯誤

## 問題分析

1. **錯誤原因**：
   - CTS 測試 `testGetDisplays` 使用 `display.getType() == Display.TYPE_OVERLAY` 來識別 overlay display
   - 如果 display type 設置錯誤，測試就無法找到 secondary display
   - 測試會認為沒有 overlay display 存在

2. **根本原因**：
   在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中：
   ```java
   // 錯誤的代碼
   mInfo.type = Display.TYPE_VIRTUAL;  // 應該是 TYPE_OVERLAY
   ```
   
   使用了錯誤的顯示器類型常量。

## Bug 位置

**文件**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `OverlayDisplayDevice.getDisplayDeviceInfoLocked()`

**行號**: 約第 358 行

## 修復方式

```java
// 修復後的代碼
mInfo.type = Display.TYPE_OVERLAY;  // 正確的類型
```

## 驗證修復

執行測試確認修復有效：
```bash
atest CtsDisplayTestCases:DisplayTest#testGetDisplays
```

## 相關知識點

1. **Display.TYPE_OVERLAY**：用於開發測試的模擬顯示器，通過 overlay window 實現
2. **Display.TYPE_VIRTUAL**：應用程式創建的虛擬顯示器
3. **Display.TYPE_INTERNAL**：內建顯示器（如手機螢幕）
4. **Display.TYPE_EXTERNAL**：外接顯示器（如 HDMI）

## 學習要點

- 不同類型的顯示器有不同的用途和行為
- CTS 測試會驗證顯示器類型的正確性
- 選擇正確的常量對於系統行為很重要
