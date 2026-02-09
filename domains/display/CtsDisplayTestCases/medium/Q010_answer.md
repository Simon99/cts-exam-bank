# Hard Q003 解答

## 問題根因

在 `VirtualDisplayAdapter.java` 的 `getDisplayDeviceInfoLocked()` 方法中，當處理 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 標誌時，雖然有檢查該標誌是否設置，但遺漏了實際設置 `DisplayDeviceInfo.FLAG_PRESENTATION` 的程式碼。

## Bug 位置

**檔案：** `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

**方法：** `VirtualDisplayDevice.getDisplayDeviceInfoLocked()`

**問題程式碼：**
```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PRESENTATION) != 0) {  // [BUG] FLAG_PRESENTATION not set
    // 缺少: mInfo.flags |= DisplayDeviceInfo.FLAG_PRESENTATION;
    
    if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0) {
        // rotation handling...
    }
}
```

## 呼叫鏈分析

```
App: DisplayManager.createVirtualDisplay(VIRTUAL_DISPLAY_FLAG_PRESENTATION)
  ↓
DisplayManagerService.createVirtualDisplayInternal()
  ↓
VirtualDisplayAdapter.createVirtualDisplayLocked()
  ↓
VirtualDisplayDevice.getDisplayDeviceInfoLocked()  ← Bug 在這裡
  ↓
DisplayDeviceInfo.flags 缺少 FLAG_PRESENTATION
  ↓
Display.getFlags() 返回錯誤的值
```

## 修復方案

在檢查 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 的 if 區塊中，加入設置 `FLAG_PRESENTATION` 的程式碼：

```java
if ((mFlags & VIRTUAL_DISPLAY_FLAG_PRESENTATION) != 0) {
    mInfo.flags |= DisplayDeviceInfo.FLAG_PRESENTATION;  // 新增這一行

    if ((mFlags & VIRTUAL_DISPLAY_FLAG_PUBLIC) != 0) {
        // For demonstration purposes, allow rotation of the external display.
        // In the future we might allow the user to configure this directly.
        if ("portrait".equals(SystemProperties.get(
                "persist.demo.remoterotation"))) {
            mInfo.rotation = Surface.ROTATION_270;
        }
    }
}
```

## 為什麼這是 Hard 級別

1. **跨層追蹤**：需要從應用程式 API 層追蹤到 system service 層的 flag 轉換
2. **理解 Flag 映射**：需要理解 `VIRTUAL_DISPLAY_FLAG_*` 和 `DisplayDeviceInfo.FLAG_*` 之間的對應關係
3. **隱蔽的 Bug**：if 條件存在，但內部操作被遺漏，容易誤以為邏輯完整
4. **需要閱讀多個相關 flag 的處理方式**：才能發現這一個與其他不同

## 驗證方式

```bash
adb shell am instrument -w -r -e class android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

修復後應該看到：
```
OK (1 test)
```
