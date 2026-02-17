# 題解：Display Brightness Mapping Bug

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java`  
**類別**: `PhysicalMappingStrategy` (內部類別)  
**方法**: `getBrightness(float lux, String packageName, int category)`  
**行號**: 約第 917-920 行

---

## 問題分析

### 有 Bug 的程式碼

```java
@Override
public float getBrightness(float lux, String packageName,
        @ApplicationInfo.Category int category) {
    float nits = mBrightnessSpline.interpolate(lux);

    // Adjust nits to compensate for display white balance colour strength.
    if (mDisplayWhiteBalanceController != null) {
        // Compensate for white balance color shift
        mDisplayWhiteBalanceController.calculateAdjustedBrightnessNits(nits);  // ❌ BUG!
    }

    float brightness = mAdjustedNitsToBrightnessSpline.interpolate(nits);
    // ... 後續處理
    return brightness;
}
```

### Bug 說明

這是一個典型的「**忘記賦值**」(Missing Assignment) 錯誤，屬於 CALC 類型的 bug。

**問題核心**:  
`calculateAdjustedBrightnessNits()` 方法返回一個調整後的 nits 值，但程式碼沒有將返回值賦回給 `nits` 變數。結果是：

1. 白平衡控制器計算了調整後的亮度值
2. 但這個計算結果被完全丟棄
3. 後續的 `interpolate(nits)` 仍使用原始的、未調整的 nits 值

### 資料流分析

```
正確流程：
  lux → nits(原始) → nits(白平衡調整後) → brightness
                      ↑
                      這裡應該更新 nits 值

錯誤流程：
  lux → nits(原始) → [白平衡計算結果被丟棄] → brightness(基於原始nits)
```

### 為什麼 CTS 測試會失敗

`BrightnessTest#testSliderEventsReflectCurves` 測試驗證：
- 在不同環境光 (lux) 條件下
- 滑動亮度滑桿時產生的亮度值
- 應該符合系統配置的亮度曲線（包含白平衡補償）

當白平衡補償被忽略時：
- 預期亮度 = f(lux, 白平衡調整)
- 實際亮度 = f(lux) ← 缺少白平衡因素
- 兩者產生顯著差異，超過測試容許的誤差範圍 (0.01)

---

## 正確的修復方案

```java
@Override
public float getBrightness(float lux, String packageName,
        @ApplicationInfo.Category int category) {
    float nits = mBrightnessSpline.interpolate(lux);

    // Adjust nits to compensate for display white balance colour strength.
    if (mDisplayWhiteBalanceController != null) {
        nits = mDisplayWhiteBalanceController.calculateAdjustedBrightnessNits(nits);  // ✅ 正確賦值
    }

    float brightness = mAdjustedNitsToBrightnessSpline.interpolate(nits);
    // Correct the brightness according to the current application and its category, but
    // only if no user data point is set (as this will override the user setting).
    if (mUserLux == -1) {
        brightness = correctBrightness(brightness, packageName, category);
    } else if (mLoggingEnabled) {
        Slog.d(TAG, "user point set, correction not applied");
    }
    return brightness;
}
```

### 修復 Patch

```diff
             // Adjust nits to compensate for display white balance colour strength.
             if (mDisplayWhiteBalanceController != null) {
-                // Compensate for white balance color shift
-                mDisplayWhiteBalanceController.calculateAdjustedBrightnessNits(nits);
+                nits = mDisplayWhiteBalanceController.calculateAdjustedBrightnessNits(nits);
             }
```

---

## 教訓與最佳實踐

### 1. 返回值必須被使用
Java 允許忽略方法返回值，但對於計算型方法（非 setter/void），返回值通常有意義。現代 IDE 和 Lint 工具會對此發出警告。

### 2. 方法命名暗示返回值
`calculateAdjustedBrightnessNits()` 這個方法名：
- `calculate` → 表示有計算
- 返回類型是 `float` → 計算結果需要被使用

### 3. Code Review 重點
在審查亮度/顯示相關程式碼時，注意：
- 資料流是否完整（輸入 → 處理 → 輸出）
- 中間計算結果是否正確傳遞
- 邊界條件檢查（nits, brightness 的有效範圍）

---

## 相關知識點

- **Android Display Subsystem**: 亮度映射策略 (BrightnessMappingStrategy)
- **Spline Interpolation**: 用於亮度曲線的平滑插值
- **Display White Balance**: 根據環境色溫調整顯示色彩的功能
- **CTS (Compatibility Test Suite)**: Android 相容性測試套件
