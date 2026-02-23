# 答案 - Display xDpi Off-by-One 錯誤

## 問題分析

1. **錯誤訊息說明**：
   - 測試期望 overlay display 的 xdpi 值為 214.0（與設定的 densityDpi 一致）
   - 但實際回報的值是 215.0，多了 1
   - 這是典型的 off-by-one 錯誤

2. **根本原因**：
   在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中：
   ```java
   // 錯誤的代碼
   mInfo.xDpi = rawMode.mDensityDpi + 1;  // 不應該加 1
   ```
   
   開發者可能在調試時加了 +1，但忘記移除。

## Bug 位置

**文件**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `OverlayDisplayDevice.getDisplayDeviceInfoLocked()`

**行號**: 約第 348 行

## 修復方式

```java
// 修復後的代碼
mInfo.xDpi = rawMode.mDensityDpi;  // 直接使用 densityDpi，不加 1
```

## 驗證修復

執行測試確認修復有效：
```bash
atest CtsDisplayTestCases:DisplayTest#testGetMetrics
```

## 相關知識點

1. **DisplayDeviceInfo.xDpi**：表示螢幕水平方向每英吋的像素數
2. **rawMode.mDensityDpi**：overlay display 配置的 DPI 值
3. **Off-by-one error**：常見的編程錯誤，在邊界處理時多算或少算一個單位

## 學習要點

- 注意數值計算時是否有多餘的 +1 或 -1
- DPI 相關的值通常應該保持一致性
- 調試代碼修改後要記得還原
