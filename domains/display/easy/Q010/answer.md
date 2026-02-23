# Q010 解答：Overlay Display 信任標記遺失

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java`

**位置**: `OverlayDisplayDevice` 內部類別的 `getDisplayDeviceInfoLocked()` 方法

## Bug 原因

在 `getDisplayDeviceInfoLocked()` 方法中，設置 `FLAG_TRUSTED` 的那行程式碼被註解掉了：

```java
// The display is trusted since it is created by system
// mInfo.flags |= FLAG_TRUSTED;  // TODO: Re-enable after testing
```

這導致 overlay display 只有 `FLAG_PRESENTATION` 標記（值為 64），而沒有 `FLAG_TRUSTED`（值為 8192）。

## 問題分析

1. **FLAG_PRESENTATION (1 << 6 = 64)**: 表示這是一個適合用於展示的顯示器
2. **FLAG_TRUSTED (1 << 13 = 8192)**: 表示這是一個受信任的顯示器，由系統建立

CTS 測試 `testFlags()` 預期 overlay display 的 flags 應該是：
```java
assertEquals(Display.FLAG_PRESENTATION | Display.FLAG_TRUSTED, display.getFlags());
// 預期值：64 | 8192 = 8256
```

由於 `FLAG_TRUSTED` 設置被註解掉，實際得到的 flags 只有 64，導致測試失敗。

## 修復方案

取消註解，恢復 `FLAG_TRUSTED` 的設置：

```java
// 修復前
// The display is trusted since it is created by system
// mInfo.flags |= FLAG_TRUSTED;  // TODO: Re-enable after testing

// 修復後
// The display is trusted since it is created by system.
mInfo.flags |= FLAG_TRUSTED;
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
+++ b/frameworks/base/services/core/java/com/android/server/display/OverlayDisplayAdapter.java
@@ -365,8 +365,8 @@ final class OverlayDisplayAdapter extends DisplayAdapter {
                 mInfo.type = Display.TYPE_OVERLAY;
                 mInfo.touch = DisplayDeviceInfo.TOUCH_VIRTUAL;
                 mInfo.state = mState;
-                // The display is trusted since it is created by system
-                // mInfo.flags |= FLAG_TRUSTED;  // TODO: Re-enable after testing
+                // The display is trusted since it is created by system.
+                mInfo.flags |= FLAG_TRUSTED;
                 mInfo.displayShape =
                         DisplayShape.createDefaultDisplayShape(mInfo.width, mInfo.height, false);
             }
```

## 學習重點

1. **調試程式碼清理**：開發過程中的 TODO 註解和暫時註解的程式碼，在合併前必須處理
2. **Flag 的重要性**：`FLAG_TRUSTED` 不只是標記，還影響系統對顯示器的信任程度和可執行的操作
3. **CTS 測試的精確性**：CTS 測試會精確檢查 flag 值，任何遺漏都會導致失敗

## 驗證修復

```bash
# 編譯修改後的 framework
cd ~/develop_claw/aosp-sandbox-1
source build/envsetup.sh
lunch aosp_panther-userdebug
m -j$(nproc)

# 刷機並執行測試
atest CtsDisplayTestCases:DisplayTest#testFlags
```
