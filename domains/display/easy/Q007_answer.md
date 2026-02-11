# 答案：VirtualDisplayAdapter resizeLocked() Bug

## Bug 位置

`VirtualDisplayAdapter.java` 第 352 行，`resizeLocked()` 方法中的條件判斷。

## Bug 描述

**錯誤程式碼：**
```java
if (mWidth != width && mHeight != height && mDensityDpi != densityDpi) {
```

**問題：** 使用了 `&&`（AND）邏輯運算符，導致只有當「寬度、高度、密度三個參數全部都改變」時，才會執行 resize 邏輯。

## 為什麼這會導致測試失敗

### 螢幕旋轉時的實際情況：

當虛擬顯示從**縱屏 (1080x1920)** 旋轉到**橫屏 (1920x1080)** 時：
- `width`: 1080 → 1920 ✅ 改變
- `height`: 1920 → 1080 ✅ 改變  
- `densityDpi`: 420 → 420 ❌ **不變**

由於 `densityDpi` 沒有改變，`mDensityDpi != densityDpi` 為 `false`。

使用 `&&` 時：`true && true && false = false`

**結果：** 整個條件為 `false`，resize 邏輯不會執行，虛擬顯示的尺寸不會更新。

### CTS 測試預期行為

`testVirtualDisplayRotatesWithContent` 測試會：
1. 創建一個帶有 `VIRTUAL_DISPLAY_FLAG_ROTATES_WITH_CONTENT` 標誌的虛擬顯示
2. 旋轉內容
3. 驗證虛擬顯示的尺寸正確地跟隨內容旋轉更新

由於 bug 導致 resize 被跳過，測試驗證尺寸時會失敗。

## 正確的修復

```java
public void resizeLocked(int width, int height, int densityDpi) {
    if (mWidth != width || mHeight != height || mDensityDpi != densityDpi) {
        sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
        sendTraversalRequestLocked();
        mWidth = width;
        mHeight = height;
        mMode = createMode(width, height, getRefreshRate());
        mDensityDpi = densityDpi;
        mInfo = null;
        mPendingChanges |= PENDING_RESIZE;
    }
}
```

**修復：** 將 `&&` 改為 `||`（OR），這樣「任一參數改變」時都會執行 resize 邏輯。

## 知識點總結

1. **邏輯運算符選擇**：當需要「任一條件成立就執行」時，使用 `||`；當需要「所有條件都成立才執行」時，使用 `&&`
2. **螢幕旋轉特性**：旋轉通常只改變寬高，不改變 DPI
3. **變更檢測邏輯**：檢測「是否需要更新」通常應該用 `||`，因為任何一個屬性變化都應觸發更新

## 修復驗證

修復後重新運行 CTS 測試：
```bash
atest android.hardware.display.cts.VirtualDisplayTest#testVirtualDisplayRotatesWithContent
```
