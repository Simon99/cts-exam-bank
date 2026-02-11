# CTS 考題解答：Virtual Display 釋放時的空指標處理缺陷

## 題目編號
DIS-M006

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**方法**：`releaseVirtualDisplayInternal()`（約第 1828-1841 行）

## Bug 分析

### 錯誤的程式碼

```java
private void releaseVirtualDisplayInternal(IBinder appToken) {
    synchronized (mSyncRoot) {
        if (mVirtualDisplayAdapter == null) {
            return;
        }

        DisplayDevice device =
                mVirtualDisplayAdapter.releaseVirtualDisplayLocked(appToken);
        Slog.d(TAG, "Virtual Display: Display Device released");
        // BUG: 缺少 null 檢查！
        // TODO: multi-display - handle virtual displays the same as other display adapters.
        mDisplayDeviceRepo.onDisplayDeviceEvent(device,
                DisplayAdapter.DISPLAY_DEVICE_EVENT_REMOVED);
    }
}
```

### 問題說明

1. **缺少 null 檢查**：`releaseVirtualDisplayLocked()` 可能返回 `null`：
   - 當 `appToken` 對應的虛擬顯示器不存在時
   - 當虛擬顯示器已經被釋放過時
   - 當應用程式使用了無效的 token 時

2. **返回值語義**：查看 `VirtualDisplayAdapter.releaseVirtualDisplayLocked()`：
   ```java
   public DisplayDevice releaseVirtualDisplayLocked(IBinder appToken) {
       VirtualDisplayDevice device = mVirtualDisplayDevices.remove(appToken);
       if (device != null) {
           Slog.v(TAG, "Release VirtualDisplay " + device.mName);
           device.destroyLocked(true);
           appToken.unlinkToDeath(device, 0);
       }
       // 注意：如果 appToken 不存在於 map 中，返回 null
       return device;
   }
   ```

3. **後果**：將 `null` 傳給 `onDisplayDeviceEvent()` 會導致：
   - NullPointerException 當嘗試存取 device 的屬性時
   - system_server 程序崩潰
   - 整個 Android 系統可能需要重啟

### 觸發條件

1. 應用程式呼叫 `releaseVirtualDisplay()` 兩次
2. 應用程式使用無效的 IBinder token
3. 虛擬顯示器在應用程式感知之前已被系統釋放（例如進程死亡時的自動清理）
4. 競態條件導致的重複釋放

## 正確的程式碼

```java
private void releaseVirtualDisplayInternal(IBinder appToken) {
    synchronized (mSyncRoot) {
        if (mVirtualDisplayAdapter == null) {
            return;
        }

        DisplayDevice device =
                mVirtualDisplayAdapter.releaseVirtualDisplayLocked(appToken);
        Slog.d(TAG, "Virtual Display: Display Device released");
        if (device != null) {
            // TODO: multi-display - handle virtual displays the same as other display adapters.
            mDisplayDeviceRepo.onDisplayDeviceEvent(device,
                    DisplayAdapter.DISPLAY_DEVICE_EVENT_REMOVED);
        }
    }
}
```

## 修復 Patch

```diff
--- a/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
+++ b/frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
@@ -1832,8 +1832,10 @@ public final class DisplayManagerService extends SystemService {
             DisplayDevice device =
                     mVirtualDisplayAdapter.releaseVirtualDisplayLocked(appToken);
             Slog.d(TAG, "Virtual Display: Display Device released");
-            // TODO: multi-display - handle virtual displays the same as other display adapters.
-            mDisplayDeviceRepo.onDisplayDeviceEvent(device,
-                    DisplayAdapter.DISPLAY_DEVICE_EVENT_REMOVED);
+            if (device != null) {
+                // TODO: multi-display - handle virtual displays the same as other display adapters.
+                mDisplayDeviceRepo.onDisplayDeviceEvent(device,
+                        DisplayAdapter.DISPLAY_DEVICE_EVENT_REMOVED);
+            }
         }
     }
```

## 關鍵知識點

1. **防禦性程式設計**：永遠檢查可能為 null 的返回值
2. **API 契約**：了解被呼叫方法的返回值語義
3. **資源生命週期**：理解虛擬顯示器的創建和銷毀流程
4. **冪等性**：釋放操作應該是冪等的，重複呼叫不應該造成錯誤

## CTS 測試關聯

`VirtualDisplayTest#testPrivateVirtualDisplay` 測試會：
1. 創建私有虛擬顯示器
2. 驗證其可用性
3. 釋放虛擬顯示器
4. 測試可能會多次呼叫 release 或測試邊界條件

當 bug 存在時，測試過程中的異常操作會觸發 NullPointerException，導致測試失敗。

## 延伸學習

- 研究 `DisplayDeviceRepository.onDisplayDeviceEvent()` 的實作
- 了解 VirtualDisplay 的完整生命週期
- 查看其他地方是否有類似的 null 檢查模式
