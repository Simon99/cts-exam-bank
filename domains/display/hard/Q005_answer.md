# 解答：Display Mode Frame Rate Override 計算錯誤

## Bug 位置

`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

方法：`getDisplayInfoForFrameRateOverride()`，約第 1115-1116 行

## 問題分析

### 錯誤的代碼

```java
// Use floor for better performance and to avoid floating point rounding issues
float numPeriodsRound = (float) Math.floor(numPeriods + 0.4999);
// Check if the difference is within acceptable bounds
if (Math.abs(numPeriods - numPeriodsRound) >= THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {
```

### 正確的代碼

```java
float numPeriodsRound = Math.round(numPeriods);
if (Math.abs(numPeriods - numPeriodsRound) > THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {
```

## Bug 詳細分析

### 問題一：Math.floor(x + 0.4999) ≠ Math.round(x)

這是一個典型的數學錯誤，看似「優化」實際上改變了行為：

| numPeriods | Math.round() | floor(x + 0.4999) | 差異 |
|------------|--------------|-------------------|------|
| 2.0 | 2 | 2 | ✓ 相同 |
| 2.4 | 2 | 2 | ✓ 相同 |
| 2.4999 | 2 | 2 | ✓ 相同 |
| **2.5** | **3** | **2** | ✗ 不同！ |
| 2.5001 | 3 | 3 | ✓ 相同 |
| 2.6 | 3 | 3 | ✓ 相同 |

**關鍵點**：`Math.round()` 遵循「四捨五入」規則，當值剛好是 0.5 時會向上取整。而 `floor(x + 0.4999)` 會將 0.5 向下取整。

### 問題二：>= vs > 的閾值錯誤

```java
// 錯誤：使用 >= 會導致剛好等於閾值的情況被拒絕
if (Math.abs(numPeriods - numPeriodsRound) >= THRESHOLD_FOR_REFRESH_RATES_DIVISORS)

// 正確：使用 > 允許剛好等於閾值的情況
if (Math.abs(numPeriods - numPeriodsRound) > THRESHOLD_FOR_REFRESH_RATES_DIVISORS)
```

當 `THRESHOLD_FOR_REFRESH_RATES_DIVISORS = 0.0009f` 時：
- 使用 `>`: 差值為 0.0009 時**接受**
- 使用 `>=`: 差值為 0.0009 時**拒絕**

### 實際影響範例

**場景**：顯示器 120Hz，應用請求 48fps

```
numPeriods = 120 / 48 = 2.5

使用 Math.round(2.5) = 3
→ frameRateHz = 120 / 3 = 40 Hz
→ 尋找 40Hz 模式或創建 override
→ 正確行為

使用 Math.floor(2.5 + 0.4999) = Math.floor(2.9999) = 2
→ frameRateHz = 120 / 2 = 60 Hz
→ 嘗試使用 60Hz 而非預期的 40Hz
→ 可能無法匹配預期模式
→ 錯誤行為
```

### 兩個 Bug 的交互作用

這兩個 bug 互相掩蓋，使得問題更難發現：

1. `floor(x + 0.4999)` 的錯誤在 x = n.5 時產生錯誤的 numPeriodsRound
2. `>=` 的閾值錯誤在邊界情況下過早拒絕有效請求
3. 當兩者同時存在時，某些情況可能「意外正確」，因為錯誤互相抵消

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -1112,10 +1112,8 @@ public final class DisplayManagerService extends SystemService {
         // in RefreshRateSelector::getFrameRateDivisor
         Display.Mode currentMode = info.getMode();
         float numPeriods = currentMode.getRefreshRate() / frameRateHz;
-        // Use floor for better performance and to avoid floating point rounding issues
-        float numPeriodsRound = (float) Math.floor(numPeriods + 0.4999);
-        // Check if the difference is within acceptable bounds
-        if (Math.abs(numPeriods - numPeriodsRound) >= THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {
+        float numPeriodsRound = Math.round(numPeriods);
+        if (Math.abs(numPeriods - numPeriodsRound) > THRESHOLD_FOR_REFRESH_RATES_DIVISORS) {
             return info;
         }
         frameRateHz = currentMode.getRefreshRate() / numPeriodsRound;
```

## 為什麼 CTS 測試能捕獲這個問題

`testGetSupportedModesOnDefaultDisplay` 測試會驗證：
1. 所有 supported modes 都能正確報告
2. Frame rate override 機制正確工作
3. 邊界情況下的行為符合規範

測試會嘗試各種 frame rate 請求組合，包括導致 `numPeriods = n.5` 的情況（如 120Hz 顯示器上請求 48fps），這會觸發這個 bug。

## 教訓

1. **不要「優化」你不完全理解的數學計算**：`floor(x + 0.4999)` 看起來像是 `round(x)` 的替代，但在邊界情況下行為不同
2. **邊界條件很重要**：`>` vs `>=` 的差異在正常情況下可能不明顯，但在精確的閾值檢查中至關重要
3. **保持與註釋的同步**：原始註釋說明這個計算需要與 native code 同步，任何變更都應該謹慎
4. **充分測試邊界情況**：單元測試應該包含 x.0、x.4999、x.5、x.5001 等邊界值

## 相關知識

### RefreshRateSelector::getFrameRateDivisor

這個 Java 計算需要與 native code 中的 `RefreshRateSelector::getFrameRateDivisor` 保持同步。使用不同的四捨五入策略會導致 Java 層和 native 層行為不一致。

### THRESHOLD_FOR_REFRESH_RATES_DIVISORS

這個閾值 (0.0009f) 允許微小的浮點數精度誤差。設計為允許差值**小於或等於**這個值的請求，所以使用 `>` 而非 `>=`。
