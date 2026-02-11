# Q010 答案：Display Mode 設置與清除事件

## Bug 位置

**檔案**：`frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

**函數**：`setUserPreferredDisplayModeInternal()`

**行號**：約 2316-2321

---

## 問題程式碼

```java
void setUserPreferredDisplayModeInternal(int displayId, Display.Mode mode) {
    synchronized (mSyncRoot) {
        // ... 參數驗證 ...

        final int resolutionHeight = mode == null ? Display.INVALID_DISPLAY_HEIGHT
                : mode.getPhysicalHeight();
        final int resolutionWidth = mode == null ? Display.INVALID_DISPLAY_WIDTH
                : mode.getPhysicalWidth();
        final float refreshRate = mode == null ? Display.INVALID_DISPLAY_REFRESH_RATE
                : mode.getRefreshRate();

        storeModeInPersistentDataStoreLocked(
                displayId, resolutionWidth, resolutionHeight, refreshRate);
        if (displayId != Display.INVALID_DISPLAY) {
            setUserPreferredModeForDisplayLocked(displayId, mode);
        } else {
            mUserPreferredMode = mode;
            // BUG: 只在 mode != null 時調用 storeModeInGlobalSettingsLocked
            // 導致 clear 操作不會通知 DisplayDevices
            if (mode != null) {  // <-- BUG: 這個條件導致 clear 時跳過事件通知
                storeModeInGlobalSettingsLocked(
                        resolutionWidth, resolutionHeight, refreshRate, mode);
            }
        }
    }
}
```

---

## 根因分析

### 問題核心

開發者可能出於「優化」目的，認為清除操作時不需要通知 DisplayDevices（避免「不必要的 display change events」）。然而這破壞了以下契約：

1. **API 契約**：`setGlobalUserPreferredDisplayMode(null)` 應該清除所有設備的 user preferred mode
2. **事件契約**：任何導致顯示配置變化的操作都應該產生 `EVENT_DISPLAY_CHANGED`

### 事件傳遞機制

```
setUserPreferredDisplayModeInternal(INVALID_DISPLAY, mode)
    ↓
storeModeInGlobalSettingsLocked(...)
    ↓
mDisplayDeviceRepo.forEachLocked((device) -> {
    device.setUserPreferredDisplayModeLocked(mode);  // 遍歷所有設備
})
    ↓
LocalDisplayDevice.setUserPreferredDisplayModeLocked(mode)
    ↓
updateDeviceInfoLocked()
    ↓
sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED)
    ↓
最終產生 EVENT_DISPLAY_CHANGED
```

### 為什麼 Set 成功但 Clear 失敗

| 操作 | mode 值 | 條件 `mode != null` | 調用 storeModeInGlobalSettingsLocked | 產生事件 |
|------|---------|---------------------|-------------------------------------|----------|
| Set  | 非 null | true | ✓ | ✓ |
| Clear | null | false | ✗ | ✗ |

---

## 正確的程式碼

```java
void setUserPreferredDisplayModeInternal(int displayId, Display.Mode mode) {
    synchronized (mSyncRoot) {
        if (mode != null && !isResolutionAndRefreshRateValid(mode)
                && displayId == Display.INVALID_DISPLAY) {
            throw new IllegalArgumentException("width, height and refresh rate of mode should "
                    + "be greater than 0 when setting the global user preferred display mode.");
        }

        final int resolutionHeight = mode == null ? Display.INVALID_DISPLAY_HEIGHT
                : mode.getPhysicalHeight();
        final int resolutionWidth = mode == null ? Display.INVALID_DISPLAY_WIDTH
                : mode.getPhysicalWidth();
        final float refreshRate = mode == null ? Display.INVALID_DISPLAY_REFRESH_RATE
                : mode.getRefreshRate();

        storeModeInPersistentDataStoreLocked(
                displayId, resolutionWidth, resolutionHeight, refreshRate);
        if (displayId != Display.INVALID_DISPLAY) {
            setUserPreferredModeForDisplayLocked(displayId, mode);
        } else {
            mUserPreferredMode = mode;
            // 無論 mode 是否為 null，都應該通知所有 DisplayDevices
            storeModeInGlobalSettingsLocked(
                    resolutionWidth, resolutionHeight, refreshRate, mode);
        }
    }
}
```

---

## 修復 Patch

```diff
@@ -2313,12 +2313,8 @@ public final class DisplayManagerService extends SystemService {
             if (displayId != Display.INVALID_DISPLAY) {
                 setUserPreferredModeForDisplayLocked(displayId, mode);
             } else {
                 mUserPreferredMode = mode;
-                // Only notify devices when setting a new mode, not when clearing
-                // to avoid unnecessary display change events during cleanup
-                if (mode != null) {
-                    storeModeInGlobalSettingsLocked(
-                            resolutionWidth, resolutionHeight, refreshRate, mode);
-                }
+                storeModeInGlobalSettingsLocked(
+                        resolutionWidth, resolutionHeight, refreshRate, mode);
             }
         }
     }
```

---

## 深入理解

### 為什麼 Clear 也需要事件

1. **應用程式監聽**：App 可能監聽 display changes 來調整 UI
2. **系統一致性**：WMS、SurfaceFlinger 等需要知道 mode 變更
3. **測試契約**：CTS 驗證 API 行為符合文檔

### storeModeInGlobalSettingsLocked 對 null mode 的處理

查看 `LocalDisplayDevice.setUserPreferredDisplayModeLocked(null)` 的實現：

```java
public void setUserPreferredDisplayModeLocked(Display.Mode mode) {
    final int oldModeId = getPreferredModeId();
    mUserPreferredMode = mode;
    
    // 當 mode 為 null 時，重置 default mode
    if (mode == null && mSystemPreferredModeId != INVALID_MODE_ID) {
        mDefaultModeId = mSystemPreferredModeId;
    }
    // ...
    
    if (oldModeId == getPreferredModeId()) {
        return;  // 無變化則不發事件
    }
    
    updateDeviceInfoLocked();  // 發送 DISPLAY_DEVICE_EVENT_CHANGED
}
```

可見 LocalDisplayDevice 已經正確處理了 `mode == null` 的情況，會：
1. 重置 `mDefaultModeId` 到系統預設值
2. 如果 mode 真的變化了，發送 display changed 事件

---

## 關鍵教訓

1. **對稱性原則**：Set 和 Clear 操作應該有對稱的行為
2. **不要過度優化**：「避免不必要的事件」可能破壞 API 契約
3. **閱讀下游處理**：下游函數（如 `setUserPreferredDisplayModeLocked`）可能已經有防重複機制

---

## 相關知識點

- Display Mode 管理架構
- DisplayManagerService 事件傳遞機制
- Global vs Per-Display 設置的差異
- CTS 測試對 API 行為的驗證
