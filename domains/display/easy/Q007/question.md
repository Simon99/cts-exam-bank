# CTS 題目：VirtualDisplayAdapter resizeLocked() Bug

## 情境

你正在調試一個虛擬顯示相關的 bug。用戶報告在使用螢幕投影 (Screen Mirroring) 功能時，
當手機從橫屏旋轉到縱屏（或反向），投影畫面沒有正確調整大小，導致畫面比例錯誤。

CTS 測試 `VirtualDisplayTest#testVirtualDisplayRotatesWithContent` 失敗。

## 問題描述

以下是 `VirtualDisplayAdapter.java` 中 `resizeLocked()` 方法的程式碼片段：

```java
public void resizeLocked(int width, int height, int densityDpi) {
    // Boundary check: only update if ALL parameters changed
    if (mWidth != width && mHeight != height && mDensityDpi != densityDpi) {
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

## 任務

1. 找出這段程式碼中的 bug
2. 解釋為什麼這個 bug 會導致 CTS 測試失敗
3. 解釋 `testVirtualDisplayRotatesWithContent` 測試預期的行為
4. 提供修正後的程式碼

## 提示

- 仔細觀察條件判斷的邏輯運算符
- 考慮螢幕旋轉時，哪些參數會變化、哪些不會變化
- 從「縱屏 1080x1920」旋轉到「橫屏 1920x1080」時，densityDpi 會變嗎？

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

## 預計完成時間

15 分鐘
