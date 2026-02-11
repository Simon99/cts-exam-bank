# Q006: 解答

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**方法**：`VirtualDisplayDevice.setSurfaceLocked()`

## 問題分析

### 原始程式碼（有 bug）

```java
public void setSurfaceLocked(Surface surface) {
    if (!mStopped && mSurface != surface) {
        if ((mSurface != null) != (surface != null)) {
            sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
        }
        sendTraversalRequestLocked();
        mSurface = surface;
        mInfo = null;
        // 缺少：mPendingChanges |= PENDING_SURFACE_CHANGE;
    }
}
```

### Bug 說明

`setSurfaceLocked()` 方法負責處理 VirtualDisplay 的 Surface 動態更新。當 Surface 變更時，程式碼：

1. ✅ 正確發送了 display event（如果 null 狀態改變）
2. ✅ 正確呼叫 `sendTraversalRequestLocked()` 請求 traversal
3. ✅ 正確更新了 `mSurface` 成員變數
4. ✅ 正確清除了 `mInfo` 快取
5. ❌ **沒有設置 `PENDING_SURFACE_CHANGE` 標誌**

### 為什麼這會造成問題

`performTraversalLocked()` 在處理 traversal 時會檢查 `mPendingChanges`：

```java
@Override
public void performTraversalLocked(SurfaceControl.Transaction t) {
    if ((mPendingChanges & PENDING_RESIZE) != 0) {
        t.setDisplaySize(getDisplayTokenLocked(), mWidth, mHeight);
    }
    if ((mPendingChanges & PENDING_SURFACE_CHANGE) != 0) {
        setSurfaceLocked(t, mSurface);  // 實際套用到 SurfaceFlinger
    }
    mPendingChanges = 0;
}
```

由於 `PENDING_SURFACE_CHANGE` 標誌沒有被設置：
- `performTraversalLocked()` 不會呼叫 `setSurfaceLocked(t, mSurface)`
- 新的 Surface 不會被設置到 SurfaceFlinger transaction 中
- SurfaceFlinger 仍然使用舊的 Surface（或 null）進行渲染
- 結果：新 Surface 永遠收不到畫面

### 狀態不一致

這個 bug 導致 Java 層和 Native 層的狀態不一致：
- Java 層：`mSurface` 已經指向新的 Surface
- Native 層（SurfaceFlinger）：仍然使用舊的 Surface

## 修正方案

```java
public void setSurfaceLocked(Surface surface) {
    if (!mStopped && mSurface != surface) {
        if ((mSurface != null) != (surface != null)) {
            sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
        }
        sendTraversalRequestLocked();
        mSurface = surface;
        mInfo = null;
        mPendingChanges |= PENDING_SURFACE_CHANGE;  // 修正：設置 pending flag
    }
}
```

## 對比 resizeLocked()

注意 `resizeLocked()` 方法正確地設置了對應的 pending flag：

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
        mPendingChanges |= PENDING_RESIZE;  // 正確設置了 flag
    }
}
```

## 關鍵教訓

1. **Pending changes pattern**：當使用 pending flags 機制來延遲處理變更時，必須確保所有相關操作都正確設置對應的 flag
2. **多層狀態同步**：Android 圖形系統涉及 Java 層和 Native 層（SurfaceFlinger），必須確保兩層的狀態保持同步
3. **一致性檢查**：類似功能的方法（如 `setSurfaceLocked` 和 `resizeLocked`）應該有一致的處理模式
