# Q008 解答：VirtualDisplay State 跨層不一致問題

## Bug 位置

**主要 Bug 檔案：** `VirtualDisplayAdapter.java`
- 類別：`VirtualDisplayDevice`
- 方法：`requestDisplayStateLocked()`
- 行號：約 385-396

## 問題分析

### 涉及的檔案（4 個檔案交互）

1. **VirtualDisplayAdapter.java** - Bug 所在位置
2. **LogicalDisplay.java** - 從 DisplayDeviceInfo 複製 state
3. **DisplayDeviceInfo.java** - 包含 state 和 committedState 欄位
4. **Display.java** - `getState()` 方法返回 DisplayInfo.state

### 根本原因

在 `VirtualDisplayAdapter.VirtualDisplayDevice` 類別中，存在兩個獨立的 state 變量：

```java
private int mDisplayState;      // 由 requestDisplayStateLocked() 更新
private boolean mIsDisplayOn;   // 由 setDisplayState() 更新
```

問題在於 `requestDisplayStateLocked()` 方法：
- ✅ 正確更新 `mDisplayState`
- ✅ 正確發送 callback (`dispatchDisplayPaused()`/`dispatchDisplayResumed()`)
- ❌ **沒有同步更新 `mIsDisplayOn`**

而 `getDisplayDeviceInfoLocked()` 中的 `mInfo.state` 是根據 `mIsDisplayOn` 決定的：

```java
mInfo.state = mIsDisplayOn ? Display.STATE_ON : Display.STATE_OFF;
```

這導致了狀態不一致：
1. `requestDisplayStateLocked(Display.STATE_OFF)` 被呼叫
2. `mDisplayState` 設為 `STATE_OFF`
3. `dispatchDisplayPaused()` 發送給應用
4. **但** `mIsDisplayOn` 仍然是 `true`
5. `DisplayDeviceInfo.state` 仍然是 `STATE_ON`
6. `Display.getState()` 返回 `STATE_ON`（錯誤！）

### 數據流追蹤

```
DisplayPowerController.updatePowerState()
    ↓ 決定 display state
DisplayPowerState.setScreenState(Display.STATE_OFF)
    ↓
mBlanker.requestDisplayState(displayId, STATE_OFF, ...)
    ↓
VirtualDisplayAdapter.VirtualDisplayDevice.requestDisplayStateLocked(STATE_OFF, ...)
    ├── mDisplayState = STATE_OFF ✓
    ├── dispatchDisplayPaused() ✓ → 應用收到 onPaused() ✓
    └── mIsDisplayOn 沒有更新 ✗ → 仍然是 true
        ↓
getDisplayDeviceInfoLocked()
    └── mInfo.state = mIsDisplayOn ? STATE_ON : STATE_OFF
        └── mInfo.state = STATE_ON (錯誤!)
            ↓
LogicalDisplay.updateDisplayInfo()
    └── mBaseDisplayInfo.state = deviceInfo.state (STATE_ON)
        ↓
Display.getState()
    └── return mDisplayInfo.state (STATE_ON) ← 與 callback 不一致！
```

## 修復方案

在 `requestDisplayStateLocked()` 中同步更新 `mIsDisplayOn`：

```java
@Override
public Runnable requestDisplayStateLocked(int state, float brightnessState,
        float sdrBrightnessState, DisplayOffloadSessionImpl displayOffloadSession) {
    if (state != mDisplayState) {
        mDisplayState = state;
        
        // FIX: Sync mIsDisplayOn with mDisplayState
        boolean isOn = (state != Display.STATE_OFF 
                && state != Display.STATE_DOZE_SUSPEND);
        if (mIsDisplayOn != isOn) {
            mIsDisplayOn = isOn;
            mInfo = null;  // Invalidate cached info
            sendDisplayDeviceEventLocked(this, DISPLAY_DEVICE_EVENT_CHANGED);
        }
        
        if (state == Display.STATE_OFF) {
            mCallback.dispatchDisplayPaused();
        } else {
            mCallback.dispatchDisplayResumed();
        }
    }
    return null;
}
```

### 修復要點

1. **同步兩個 state 變量**：確保 `mIsDisplayOn` 和 `mDisplayState` 保持一致
2. **考慮 DOZE 狀態**：`STATE_DOZE_SUSPEND` 也應被視為 "off" 狀態
3. **失效緩存**：設置 `mInfo = null` 強制重新生成 DisplayDeviceInfo
4. **發送事件**：調用 `sendDisplayDeviceEventLocked()` 通知系統狀態變化

## 為什麼這是個多檔案交互問題

這個 bug 需要理解跨 4 個檔案的數據流：

| 檔案 | 角色 |
|------|------|
| VirtualDisplayAdapter.java | 管理虛擬顯示設備狀態 |
| DisplayDeviceInfo.java | 設備資訊的資料結構 |
| LogicalDisplay.java | 從 DisplayDeviceInfo 複製到 DisplayInfo |
| Display.java | 應用層 API，返回 DisplayInfo.state |

只看單一檔案無法發現問題，必須追蹤整個數據流才能理解為什麼 callback 和 `getState()` 不一致。

## 驗證方法

修復後，以下測試應該通過：

```bash
adb shell am instrument -w -e class \
    android.display.cts.VirtualDisplayTest#testVirtualDisplayStateConsistency \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

預期行為：
1. 創建 VirtualDisplay，確認 `getState()` == `STATE_ON`
2. 系統請求 display off
3. 收到 `onPaused()` callback
4. `getState()` 應返回 `STATE_OFF`（現在一致了）
