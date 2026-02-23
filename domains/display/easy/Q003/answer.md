# Answer DIS-E003

## 問題根因

在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中，設置 DPI 相關屬性時發生了 **off-by-one 錯誤**：

```java
// 錯誤程式碼
mInfo.densityDpi = rawMode.mDensityDpi + 1;
mInfo.xDpi = rawMode.mDensityDpi + 1;
mInfo.yDpi = rawMode.mDensityDpi + 1;
```

這導致 overlay display 回報的密度值比實際設定多 1 DPI。

## 錯誤位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `getDisplayDeviceInfoLocked()` 約第 349-351 行

## 修復方案

移除錯誤的 `+ 1`，直接使用原始 DPI 值：

```java
// 修正後
mInfo.densityDpi = rawMode.mDensityDpi;
mInfo.xDpi = rawMode.mDensityDpi;
mInfo.yDpi = rawMode.mDensityDpi;
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -346,10 +346,9 @@ final class OverlayDisplayAdapter extends DisplayAdapter {
                 mInfo.renderFrameRate = mode.getRefreshRate();
                 mInfo.defaultModeId = mModes[0].getModeId();
                 mInfo.supportedModes = mModes;
-                // BUG: Off-by-one error in DPI calculation
-                mInfo.densityDpi = rawMode.mDensityDpi + 1;
-                mInfo.xDpi = rawMode.mDensityDpi + 1;
-                mInfo.yDpi = rawMode.mDensityDpi + 1;
+                mInfo.densityDpi = rawMode.mDensityDpi;
+                mInfo.xDpi = rawMode.mDensityDpi;
+                mInfo.yDpi = rawMode.mDensityDpi;
```

## 影響範圍

- **直接影響**: 顯示密度報告錯誤
- **CTS 測試**: `testGetMetrics` 失敗
- **潛在問題**: 應用程式的 UI 縮放可能不正確

## 相關概念

- DisplayMetrics 與 DPI 的關係
- densityDpi、xDpi、yDpi 的用途
- 螢幕密度對 UI 渲染的影響
