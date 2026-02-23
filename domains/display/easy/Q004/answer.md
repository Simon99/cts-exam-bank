# Answer DIS-E004

## 問題根因

在 `OverlayDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中，`defaultModeId` 被設為無效值 `-1`：

```java
// 錯誤程式碼
mInfo.defaultModeId = -1;
```

這導致 overlay display 無法正確報告預設顯示模式。

## 錯誤位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**方法**: `getDisplayDeviceInfoLocked()` 約第 347 行

## 修復方案

將 `defaultModeId` 設為第一個支援的模式 ID：

```java
// 修正後
mInfo.defaultModeId = mModes[0].getModeId();
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -344,8 +344,7 @@ final class OverlayDisplayAdapter extends DisplayAdapter {
                 mInfo.height = mode.getPhysicalHeight();
                 mInfo.modeId = mode.getModeId();
                 mInfo.renderFrameRate = mode.getRefreshRate();
-                // BUG: Using invalid mode ID instead of first supported mode
-                mInfo.defaultModeId = -1;
+                mInfo.defaultModeId = mModes[0].getModeId();
                 mInfo.supportedModes = mModes;
```

## 影響範圍

- **直接影響**: 顯示器預設模式報告錯誤
- **CTS 測試**: `testMode` 失敗
- **潛在問題**: 應用程式可能無法正確獲取顯示模式資訊

## 相關概念

- Display.Mode 類別結構
- defaultModeId 與 supportedModes 的關係
- 顯示模式管理機制
