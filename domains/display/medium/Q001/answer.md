# DIS-M001: 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java`

**問題代碼** (約第 321 行):
```java
for (int j = 0; j < displayModes.length - 1; j++) {
    SurfaceControl.DisplayMode other = displayModes[j];
    boolean isAlternative = j != i && other.width == mode.width
            && other.height == mode.height
            && other.peakRefreshRate != mode.peakRefreshRate
            && other.group == mode.group;
    if (isAlternative) {
        alternativeRefreshRates.add(displayModes[j].peakRefreshRate);
    }
}
```

## 問題分析

### 根本原因

經典的 **Off-by-One Error（差一錯誤）**。迴圈終止條件使用了 `displayModes.length - 1`，導致陣列中最後一個 display mode 永遠不會被考慮為任何模式的 alternative。

### 詳細說明

1. **Alternative Refresh Rates 的對稱性要求**:
   - 根據 API 文件：`getAlternativeRefreshRates()` 回傳的關係是對稱的
   - 如果 Mode A (60Hz) 的 alternatives 包含 90Hz，那麼 Mode B (90Hz) 的 alternatives 必須包含 60Hz

2. **Bug 導致的行為**:
   假設 displayModes 陣列包含: `[60Hz, 90Hz, 120Hz]`（同解析度同 group）
   
   - 計算 60Hz 的 alternatives 時，j 只會遍歷到 90Hz（index 0, 1），跳過 120Hz
   - 60Hz 的 alternatives = `[90Hz]`，**缺少 120Hz**
   - 計算 120Hz 的 alternatives 時，j 會遍歷 60Hz 和 90Hz
   - 120Hz 的 alternatives = `[60Hz, 90Hz]`，包含 60Hz
   
   **對稱性被破壞**: 120Hz 認為 60Hz 是 alternative，但 60Hz 不認為 120Hz 是 alternative

3. **為什麼第一次查詢更容易重現**:
   - DisplayModeRecord 有快取機制（`findDisplayModeRecord()`）
   - 第一次啟動時，快取為空，所有 modes 都需要重新計算
   - 如果最後一個 mode 的 refresh rate 是 unique 的（如最高的 120Hz），bug 就會暴露
   - 後續查詢如果快取命中，可能使用舊的（正確的）數據

### 正確的迴圈條件

```java
for (int j = 0; j < displayModes.length; j++) {
```

應該遍歷**所有**元素，包括最後一個。

## 正確修復

```java
for (int j = 0; j < displayModes.length; j++) {
    SurfaceControl.DisplayMode other = displayModes[j];
    boolean isAlternative = j != i && other.width == mode.width
            && other.height == mode.height
            && other.peakRefreshRate != mode.peakRefreshRate
            && other.group == mode.group;
    if (isAlternative) {
        alternativeRefreshRates.add(displayModes[j].peakRefreshRate);
    }
}
```

## 驗證方式

修復後重新執行:
```bash
atest CtsDisplayTestCases:DisplayTest#testGetSupportedModesOnDefaultDisplay
```

## 學習要點

1. **Off-by-One Error**: 最常見的邊界錯誤之一，特別在陣列遍歷時
2. **對稱關係的驗證**: 當 API 承諾某種數學性質（對稱、傳遞），實作必須確保所有元素都被正確處理
3. **快取遮蔽 Bug**: 快取機制可能讓 bug 難以穩定重現
4. **邊界測試的重要性**: 陣列的第一個和最後一個元素是 off-by-one 錯誤的常見受害者
