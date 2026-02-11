# CTS 題目：Display Per-Display Brightness Configuration 設定失敗

## 背景

你正在除錯 Android 14 Display 子系統。CTS 測試報告以下失敗：

```
android.hardware.display.cts.BrightnessTest#testSetAndGetPerDisplay FAILED
```

測試發現：呼叫 `setBrightnessConfigurationForDisplay()` 設定特定顯示器的亮度曲線後，使用 `getBrightnessConfigurationForDisplay()` 取回的配置為 null 或預設值，而非剛設定的配置。

## 症狀

1. **Per-display brightness configuration 無法設定** — 系統無法為特定顯示器儲存自訂亮度曲線
2. **Get 回傳值與 Set 不一致** — 設定後立即讀取，結果不符預期
3. **實際亮度行為不變** — 亮度曲線設定沒有生效

## 測試環境

- 設備：Pixel 7 (panther)
- Android 版本：14 (API 34)
- 測試模組：CtsDisplayTestCases

## CTS 測試程式碼片段

```java
// 設定自訂亮度曲線
BrightnessConfiguration.Builder builder = new BrightnessConfiguration.Builder(
    new float[]{0, 500, 5000},   // lux levels
    new float[]{0.1f, 0.5f, 1.0f}  // nits
);
BrightnessConfiguration config = builder.build();

displayManager.setBrightnessConfigurationForDisplay(config, uniqueId);

// 驗證設定結果
BrightnessConfiguration retrieved = displayManager.getBrightnessConfigurationForDisplay(uniqueId);
assertEquals(config, retrieved);  // 這裡失敗！
```

## 可疑區域

DisplayManagerService.java 中的 `setBrightnessConfigurationForDisplayInternal()` 方法負責處理亮度配置設定。

## 你的任務

1. 分析 `setBrightnessConfigurationForDisplayInternal()` 的邏輯
2. 找出導致配置無法正確儲存的 bug
3. 提供正確的修復方案

## 提示

- 檢查函數開頭的驗證和設備查詢邏輯
- 注意條件判斷的正確性
- 思考什麼情況下函數會提前返回
