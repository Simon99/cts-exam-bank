# DIS-M006: VirtualDisplay 私有標誌設定錯誤

## 背景

某 Android Framework 版本在 CTS `android.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay` 測試中持續失敗，錯誤訊息顯示 display flags 驗證失敗：

```
junit.framework.AssertionFailedError: display must have correct flags
Expected: 4 (FLAG_PRIVATE)
Actual: 0
```

測試預期私有 virtual display 應該有 `FLAG_PRIVATE` 標誌，但實際上沒有被設定。

## 問題描述

一位開發者在重構 `VirtualDisplayAdapter` 的程式碼時，修改了判斷 display 是否為私有的條件邏輯。這個錯誤導致所有私有 virtual display 的 flag 都沒有被正確設定。

請審查以下程式碼片段，找出導致 CTS 測試失敗的原因：

**檔案：** `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

```java
@Override
public DisplayDeviceInfo getDisplayDeviceInfoLocked() {
    if (mInfo == null) {
        mInfo = new DisplayDeviceInfo();
        mInfo.name = mName;
        mInfo.uniqueId = getUniqueId();
        mInfo.width = mWidth;
        mInfo.height = mHeight;
        mInfo.modeId = mMode.getModeId();
        mInfo.renderFrameRate = mMode.getRefreshRate();
        mInfo.defaultModeId = mMode.getModeId();
        mInfo.supportedModes = new Display.Mode[] { mMode };
        mInfo.densityDpi = mDensityDpi;
        mInfo.xDpi = mDensityDpi;
        mInfo.yDpi = mDensityDpi;
        mInfo.presentationDeadlineNanos = 1000000000L / (int) getRefreshRate();
        mInfo.flags = 0;
        if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0) {  // ← 問題可能在這裡
            mInfo.flags |= DisplayDeviceInfo.FLAG_PRIVATE
                    | DisplayDeviceInfo.FLAG_NEVER_BLANK;
        }
        if ((mFlags & VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR) != 0) {
            mInfo.flags &= ~DisplayDeviceInfo.FLAG_NEVER_BLANK;
        } else {
            mInfo.flags |= DisplayDeviceInfo.FLAG_OWN_CONTENT_ONLY;
            // ... 更多 flag 處理 ...
        }
        // ... 省略其他 flag 處理 ...
    }
    return mInfo;
}
```

## 選項

**A.** 條件 `(mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0` 邏輯錯誤 — 應為 `== 0` 才能正確識別私有 display

**B.** `DisplayDeviceInfo.FLAG_PRIVATE` 常數值錯誤，應該直接使用 `Display.FLAG_PRIVATE`

**C.** 缺少對 `VIRTUAL_DISPLAY_FLAG_SECURE` 的檢查，需要同時設定 secure flag 才能識別私有 display

**D.** `mInfo.flags` 應初始化為 `FLAG_PRIVATE` 而非 `0`，避免後續條件判斷失效
