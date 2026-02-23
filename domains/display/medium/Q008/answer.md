# 答案解析：LogicalDisplay.updateLocked 寬高互換 Bug

## 正確答案：B

## 解析

在 `LogicalDisplay.updateLocked()` 方法中，當設定 `mBaseDisplayInfo` 的 `appWidth` 和 `appHeight` 時，錯誤地將值互換了：

**錯誤程式碼：**
```java
mBaseDisplayInfo.appWidth = maskedHeight;    // 錯！應該是 maskedWidth
mBaseDisplayInfo.appHeight = maskedWidth;    // 錯！應該是 maskedHeight
```

**正確程式碼應為：**
```java
mBaseDisplayInfo.appWidth = maskedWidth;
mBaseDisplayInfo.appHeight = maskedHeight;
```

## 呼叫鏈追蹤

```
DisplayTest.testGetMetrics()
    ↓
Display.getMetrics(outMetrics)
    ↓
Display.updateDisplayInfoLocked()
    ↓
DisplayManagerGlobal.getDisplayInfo(displayId)
    ↓
IDisplayManager.getDisplayInfo() [Binder IPC]
    ↓
DisplayManagerService.getDisplayInfoInternal()
    ↓
LogicalDisplay.getDisplayInfoLocked()
    ↓
返回 mBaseDisplayInfo（appWidth/appHeight 在 updateLocked() 中被互換）
```

## 為什麼選項 B 正確

1. CTS 測試創建了一個 181x161（寬x高）的 overlay display
2. `LogicalDisplay.updateLocked()` 設定所有 display 的基礎資訊（`mBaseDisplayInfo`）
3. 由於 `appWidth = maskedHeight = 161` 和 `appHeight = maskedWidth = 181`
4. 當 `Display.getMetrics()` 查詢時，取得的 `widthPixels` 變成了 161（原本應該是 181）
5. 測試斷言 `widthPixels == 181` 失敗

## 為什麼其他選項錯誤

**A. `logicalWidth` 和 `logicalHeight` 的賦值順序錯誤**
- 這兩個欄位的賦值是正確的：`logicalWidth = maskedWidth`, `logicalHeight = maskedHeight`
- 而且 `getMetrics()` 取的是 `appWidth/appHeight`，不是 `logicalWidth/logicalHeight`

**C. `maskedWidth` 和 `maskedHeight` 的計算公式錯誤**
- 計算公式是正確的：
  - `maskedWidth = deviceInfo.width - maskingInsets.left - maskingInsets.right`
  - `maskedHeight = deviceInfo.height - maskingInsets.top - maskingInsets.bottom`

**D. `deviceInfo.width` 和 `deviceInfo.height` 本身就是錯誤的**
- `deviceInfo` 來自 DisplayDevice，這是硬體提供的原始資訊
- 錯誤發生在 Framework 層的賦值，不是硬體層

## 修復方式

```java
// 修正 appWidth 和 appHeight 的賦值
mBaseDisplayInfo.appWidth = maskedWidth;
mBaseDisplayInfo.appHeight = maskedHeight;
```

## 關鍵知識點

1. **LogicalDisplay vs DisplayDevice**：
   - `DisplayDevice` 代表實體或虛擬顯示裝置
   - `LogicalDisplay` 是系統對外暴露的邏輯顯示，包含 base info 和可選的 override info

2. **DisplayInfo 欄位的來源**：
   - `mBaseDisplayInfo`：基礎資訊，由 `updateLocked()` 設定，影響所有 display
   - `mOverrideDisplayInfo`：WindowManager 提供的覆蓋資訊（主要用於 Primary Display）

3. **getMetrics() 的資料流**：
   - App 呼叫 `Display.getMetrics()` 
   - 透過 Binder 向 DisplayManagerService 查詢
   - 最終回傳 `LogicalDisplay.getDisplayInfoLocked()` 的結果
