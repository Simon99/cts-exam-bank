# DIS-M002 解答

## Bug 位置

**檔案**: `frameworks/base/core/java/android/view/DisplayInfo.java`

**行數**: 第 797 行（getMetricsWithSize 方法內）

## 完整呼叫鏈（含行號）

```
CTS: DisplayTest#testGetMetrics                   [DisplayTest.java:607]
  │
  │  // 創建 overlay display: 181x161/214
  │  // display.getMetrics(outMetrics)
  ▼
Display.getMetrics(outMetrics)                    [Display.java:1622]
  │  synchronized (mLock) {
  │      updateDisplayInfoLocked();
  │      mDisplayInfo.getAppMetrics(outMetrics, getDisplayAdjustments());
  │  }
  ▼
DisplayInfo.getAppMetrics(outMetrics, adj)        [DisplayInfo.java:729-731]
  │  getMetricsWithSize(outMetrics, adj.getCompatibilityInfo(),
  │      adj.getConfiguration(), appWidth, appHeight);
  ▼
getMetricsWithSize(...)                           [DisplayInfo.java:795-815]
  │
  │  Line 797: outMetrics.densityDpi = logicalDensityDpi + 1;  ← BUG!
  │  Line 801: outMetrics.xdpi = physicalXDpi;
  │  Line 802: outMetrics.ydpi = physicalYDpi;
  │
  ▼
CTS 斷言失敗                                       [DisplayTest.java:648]
  │  assertEquals(SECONDARY_DISPLAY_DPI, outMetrics.densityDpi);
  │  // Expected: 214, Actual: 215
```

## Bug 分析

### 問題程式碼

```java
private void getMetricsWithSize(DisplayMetrics outMetrics, CompatibilityInfo compatInfo,
        Configuration configuration, int width, int height) {
    outMetrics.densityDpi = outMetrics.noncompatDensityDpi = logicalDensityDpi + 1;  // ❌ BUG
    outMetrics.density = outMetrics.noncompatDensity =
            logicalDensityDpi * DisplayMetrics.DENSITY_DEFAULT_SCALE;
    // ...
}
```

### 根本原因

這是典型的「off-by-one 錯誤」：
1. 在設定 `outMetrics.densityDpi` 時，錯誤地將 `logicalDensityDpi + 1` 賦值
2. 可能是調試時加的偏移量忘記移除
3. 或是誤解了 DPI 的計算方式

### 為什麼 CTS 測試會失敗

1. CTS 測試創建一個 DPI 為 214 的 overlay display
2. 呼叫 `display.getMetrics()` 取得 DisplayMetrics
3. `getMetricsWithSize()` 將 `logicalDensityDpi + 1 = 215` 賦值給 `densityDpi`
4. 測試斷言 `assertEquals(214, outMetrics.densityDpi)` 失敗

### 為什麼這是個嚴重問題

- densityDpi 影響 UI 元素的縮放
- 即使差 1，也會導致與其他 density 相關計算不一致
- 例如：`density = logicalDensityDpi * DENSITY_DEFAULT_SCALE` 仍使用原值
- 這會造成 density 和 densityDpi 之間的不一致

## 修復方案

```java
private void getMetricsWithSize(DisplayMetrics outMetrics, CompatibilityInfo compatInfo,
        Configuration configuration, int width, int height) {
    outMetrics.densityDpi = outMetrics.noncompatDensityDpi = logicalDensityDpi;  // ✅ 修正
    outMetrics.density = outMetrics.noncompatDensity =
            logicalDensityDpi * DisplayMetrics.DENSITY_DEFAULT_SCALE;
    // ...
}
```

## 修復 Patch

```diff
--- a/frameworks/base/core/java/android/view/DisplayInfo.java
+++ b/frameworks/base/core/java/android/view/DisplayInfo.java
@@ -794,7 +794,7 @@ public final class DisplayInfo implements Parcelable {
 
     private void getMetricsWithSize(DisplayMetrics outMetrics, CompatibilityInfo compatInfo,
             Configuration configuration, int width, int height) {
-        outMetrics.densityDpi = outMetrics.noncompatDensityDpi = logicalDensityDpi + 1;
+        outMetrics.densityDpi = outMetrics.noncompatDensityDpi = logicalDensityDpi;
         outMetrics.density = outMetrics.noncompatDensity =
                 logicalDensityDpi * DisplayMetrics.DENSITY_DEFAULT_SCALE;
         outMetrics.scaledDensity = outMetrics.noncompatScaledDensity = outMetrics.density;
```

## 學習重點

1. **追蹤完整呼叫鏈**：從 CTS 測試 → Display.getMetrics() → DisplayInfo.getAppMetrics() → getMetricsWithSize()
2. **識別 off-by-one 錯誤**：差 1 的誤差通常指向簡單的算術錯誤
3. **理解 DisplayMetrics 結構**：density, densityDpi, xdpi, ydpi 各有不同用途
4. **getMetricsWithSize 是核心路徑**：所有 getMetrics/getAppMetrics/getLogicalMetrics 最終都呼叫這個方法
