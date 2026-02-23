# Answer DIS-E002

## 問題根因

在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中，設置顯示器高度時發生了 **off-by-one 錯誤**：

```java
// 錯誤程式碼
mInfo.height = mode.getPhysicalHeight() + 1;
```

這導致 overlay display 回報的高度比實際設定多 1 像素。

## 錯誤位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `getDisplayDeviceInfoLocked()` 約第 344 行

## 修復方案

移除錯誤的 `+ 1`，直接使用 mode 中的正確高度：

```java
// 修正後
mInfo.height = mode.getPhysicalHeight();
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -341,8 +341,7 @@ final class OverlayDisplayAdapter extends DisplayAdapter {
                 mInfo = new DisplayDeviceInfo();
                 mInfo.name = mName;
                 mInfo.uniqueId = getUniqueId();
                 mInfo.width = mode.getPhysicalWidth();
-                // BUG: Off-by-one error in height calculation
-                mInfo.height = mode.getPhysicalHeight() + 1;
+                mInfo.height = mode.getPhysicalHeight();
```

## 影響範圍

- **直接影響**: Overlay display 高度報告錯誤
- **CTS 測試**: `testGetDisplayAttrs` 失敗
- **潛在問題**: 應用程式可能出現垂直方向的顯示錯位

## 相關概念

- DisplayDeviceInfo 屬性設置
- OverlayDisplayAdapter 的尺寸處理
- Display.getHeight() 與實際物理尺寸的關係
