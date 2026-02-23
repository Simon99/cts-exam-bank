# Answer DIS-E001

## 問題根因

在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中，設置顯示器寬度時發生了 **off-by-one 錯誤**：

```java
// 錯誤程式碼
mInfo.width = mode.getPhysicalWidth() + 1;
```

這導致 overlay display 回報的寬度比實際設定多 1 像素。

## 錯誤位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `getDisplayDeviceInfoLocked()` 約第 343 行

## 修復方案

移除錯誤的 `+ 1`，直接使用 mode 中的正確寬度：

```java
// 修正後
mInfo.width = mode.getPhysicalWidth();
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -340,8 +340,7 @@ final class OverlayDisplayAdapter extends DisplayAdapter {
             if (mInfo == null) {
                 mInfo = new DisplayDeviceInfo();
                 mInfo.name = mName;
                 mInfo.uniqueId = getUniqueId();
-                // BUG: Off-by-one error in width calculation
-                mInfo.width = mode.getPhysicalWidth() + 1;
+                mInfo.width = mode.getPhysicalWidth();
                 mInfo.height = mode.getPhysicalHeight();
```

## 影響範圍

- **直接影響**: Overlay display 寬度報告錯誤
- **CTS 測試**: `testGetDisplayAttrs` 失敗
- **潛在問題**: 使用 overlay display 的應用可能出現顯示錯位

## 相關概念

- DisplayDeviceInfo 屬性設置
- OverlayDisplayAdapter 的 DisplayDevice 實作
- CTS 顯示模組測試
