# CTS 面試題解答：Display - Easy - Q001

## 1. Bug 識別

**錯誤位置**: 第 302 行的 for 迴圈條件

```java
// 錯誤的程式碼
for (int i = 0; i <= events.length; ++i)

// 正確的程式碼
for (int i = 0; i < events.length; ++i)
```

**錯誤類型**: Off-by-one error（差一錯誤）/ 邊界條件錯誤

## 2. 錯誤原因分析

### 陣列索引範圍
- Java 陣列索引從 `0` 開始，到 `length - 1` 結束
- 對於長度為 `n` 的陣列，有效索引為 `0, 1, 2, ..., n-1`

### 錯誤的邊界條件
- `i <= events.length` 允許 `i` 達到 `events.length`
- 當 `i == events.length` 時，`events[i]` 訪問的是陣列外的記憶體
- 這會立即觸發 `ArrayIndexOutOfBoundsException`

### 觸發條件
- 只要 `events` 陣列非空（`events.length > 0`），迴圈就會嘗試訪問 `events[events.length]`
- 即使 `events` 為空陣列（`length == 0`），條件 `0 <= 0` 仍為 true，會嘗試訪問 `events[0]`

## 3. 正確修復

```java
// 修復：將 <= 改為 <
for (int i = 0; i < events.length; ++i) {
    Boolean redact = toRedact.get(events[i].userId);
    // ... 其餘程式碼不變
}
```

## 4. 影響分析

### 直接影響
- **Crash**: 任何調用 `getEvents()` 的操作都會崩潰
- **功能失效**: 亮度滑桿追蹤功能完全無法使用
- **CTS 失敗**: `BrightnessTest#testBrightnessSliderTracking` 必定失敗

### 相關系統功能
- 自適應亮度學習功能失效
- 亮度歷史記錄無法讀取
- 系統設定中的亮度使用統計無法顯示

## 5. Unified Diff Patch（修復版）

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java
+++ b/frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java
@@ -299,7 +299,7 @@ public class BrightnessTracker {
             toRedact.put(profiles[i], redact);
         }
         ArrayList<BrightnessChangeEvent> out = new ArrayList<>(events.length);
-        for (int i = 0; i <= events.length; ++i) {
+        for (int i = 0; i < events.length; ++i) {
             Boolean redact = toRedact.get(events[i].userId);
             if (redact != null) {
                 if (!redact) {
```

## 6. 延伸討論

### 為什麼這是常見錯誤？
- 開發者可能誤以為「遍歷所有元素」需要 `<=`
- 從 1-indexed 語言（如 MATLAB、Lua）轉來的開發者容易犯此錯
- 快速打字時 `<` 和 `<=` 容易混淆

### 如何預防？
1. **使用 enhanced for-loop**: `for (BrightnessChangeEvent event : events)`
2. **程式碼審查**: 特別注意迴圈邊界條件
3. **單元測試**: 測試空陣列和單元素陣列的邊界情況
4. **靜態分析工具**: 使用 FindBugs/SpotBugs 等工具檢測

## 評分標準

| 項目 | 分數 | 標準 |
|-----|-----|------|
| 識別 bug | 30% | 正確指出 `<=` 應為 `<` |
| 解釋原因 | 25% | 說明陣列索引範圍和越界原因 |
| 提出修復 | 25% | 給出正確的修復程式碼 |
| 影響分析 | 20% | 分析對系統功能的影響 |
