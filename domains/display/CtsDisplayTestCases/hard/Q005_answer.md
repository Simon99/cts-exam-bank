# H-Q005: 答案

## Bug 位置

**檔案:** `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**問題:** density 計算時整數除法先執行，導致精度丟失

## 調用鏈分析

```
DisplayManagerService.configureDisplayLocked()           ← A: 配置顯示參數，打 log
    ↓
LogicalDisplay.configureDisplayLocked()                  ← B: 計算 display info
    ↓
OverlayDisplayAdapter.getDisplayDeviceInfoLocked()       ← C: 計算 metrics，BUG 在這
```

### A 層（DisplayManagerService）
```java
void configureDisplayLocked(int displayId) {
    Slog.d(TAG, "Configuring display: " + displayId);
    LogicalDisplay display = mLogicalDisplays.get(displayId);
    display.configureDisplayLocked(mContext);
}
```

### B 層（LogicalDisplay）
```java
void configureDisplayLocked(Context context) {
    DisplayDeviceInfo deviceInfo = mPrimaryDisplayDevice.getDisplayDeviceInfoLocked();
    mBaseDisplayInfo.logicalDensityDpi = deviceInfo.densityDpi;
}
```

### C 層（OverlayDisplayAdapter.OverlayDisplayDevice）— BUG
```java
// 正確版本
public DisplayDeviceInfo getDisplayDeviceInfoLocked() {
    // density = width * defaultDensity / defaultWidth
    mInfo.densityDpi = mWidth * DEFAULT_DENSITY_DPI / DEFAULT_WIDTH;
    return mInfo;
}

// Bug 版本
public DisplayDeviceInfo getDisplayDeviceInfoLocked() {
    // [BUG] 整數除法先執行，精度丟失
    // density = (width / defaultWidth) * defaultDensity
    mInfo.densityDpi = (mWidth / DEFAULT_WIDTH) * DEFAULT_DENSITY_DPI;
    return mInfo;
}
```

### 邏輯分析

假設：
- mWidth = 720
- DEFAULT_WIDTH = 1080
- DEFAULT_DENSITY_DPI = 480

**正確計算：**
```
density = 720 * 480 / 1080 = 345600 / 1080 = 320
```

**Bug 計算：**
```
density = (720 / 1080) * 480 = 0 * 480 = 0  // 整數除法 720/1080 = 0
```

或者如果 mWidth = 1440：
```
正確：1440 * 480 / 1080 = 640
Bug：(1440 / 1080) * 480 = 1 * 480 = 480  // 精度丟失
```

## 修復方案

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -xxx,7 +xxx,7 @@ class OverlayDisplayAdapter {
     class OverlayDisplayDevice extends DisplayDevice {
         public DisplayDeviceInfo getDisplayDeviceInfoLocked() {
-            mInfo.densityDpi = mWidth * DEFAULT_DENSITY_DPI / DEFAULT_WIDTH;
+            mInfo.densityDpi = (mWidth / DEFAULT_WIDTH) * DEFAULT_DENSITY_DPI;
             return mInfo;
         }
     }
 }
```

## 診斷技巧

1. **分析數值差異** - 結果是預期的一半，可能是運算問題
2. **追蹤到 OverlayDisplayAdapter** - 這是 overlay display 的專用 adapter
3. **檢查 density 計算** - 發現運算順序導致精度丟失
4. **理解整數除法** - 先除後乘 vs 先乘後除的差異

## 評分標準

| 項目 | 分數 |
|------|------|
| 理解 overlay display 的特殊性 | 15% |
| 追蹤到 OverlayDisplayAdapter | 25% |
| 找到 getDisplayDeviceInfoLocked | 25% |
| 識別出整數除法精度問題 | 35% |
