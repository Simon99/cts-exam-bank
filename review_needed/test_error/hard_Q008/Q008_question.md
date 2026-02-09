# CTS Hard Q008: VirtualDisplay State 跨層不一致問題

## 難度：Hard (多檔案交互)

## 問題描述

在使用 VirtualDisplay 進行螢幕錄製或投影時，當系統進入低電量模式或用戶關閉螢幕時，
VirtualDisplay 的 callback 會正確觸發 `onPaused()`，但應用透過 `Display.getState()` 
查詢的狀態仍然顯示為 `STATE_ON`，導致狀態不一致。

## 復現步驟

1. 創建一個 VirtualDisplay 並註冊 `VirtualDisplay.Callback`
2. 確認初始狀態：`Display.getState()` 返回 `STATE_ON`
3. 透過 ADB 模擬系統請求 display off：
   ```
   adb shell cmd display set-screen-power-state OFF
   ```
4. **預期行為：**
   - 收到 `VirtualDisplay.Callback.onPaused()` 回調
   - `Display.getState()` 返回 `STATE_OFF`
5. **實際行為：**
   - 收到 `VirtualDisplay.Callback.onPaused()` 回調 ✓
   - `Display.getState()` 仍返回 `STATE_ON` ✗

## 涉及的 CTS 測試

```
adb shell am instrument -w -e class \
    android.display.cts.VirtualDisplayTest#testVirtualDisplayStateConsistency \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

## 測試失敗日誌

```
junit.framework.AssertionFailedError: 
Display state should be consistent with callback:
  Callback received: onPaused (expecting STATE_OFF)
  Display.getState() returned: STATE_ON
  Expected: STATE_OFF (2)
  Actual: STATE_ON (1)

Display.STATE_ON = 2
Display.STATE_OFF = 1
Display.STATE_DOZE = 3
Display.STATE_DOZE_SUSPEND = 4
```

## 架構說明

VirtualDisplay 狀態變化的數據流：
```
DisplayPowerController
    ↓ (power state change)
DisplayPowerState.requestDisplayState()
    ↓
DisplayBlanker.requestDisplayState()
    ↓
VirtualDisplayAdapter.VirtualDisplayDevice.requestDisplayStateLocked()
    ↓
    ├── mDisplayState = state           [更新內部狀態]
    ├── Callback.dispatchDisplayPaused()  [發送 callback]
    └── mIsDisplayOn = ???              [是否同步更新?]
    ↓
DisplayDeviceInfo.state                  [由 mIsDisplayOn 決定]
    ↓
LogicalDisplay.mBaseDisplayInfo.state
    ↓
Display.getState()                       [應用層查詢]
```

## 你的任務

1. 分析 VirtualDisplay state 的跨層傳遞流程
2. 找出為什麼 callback 正確觸發但 `Display.getState()` 返回錯誤值
3. 識別涉及的 3+ 個檔案之間的交互問題
4. 提供修復方案

## 相關源代碼路徑

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
- `frameworks/base/core/java/android/view/Display.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`

## 調試提示

- 觀察 VirtualDisplayAdapter 中有哪些與 state 相關的成員變量
- 思考 `requestDisplayStateLocked()` 和 `setDisplayState()` 的區別
- 分析 `getDisplayDeviceInfoLocked()` 如何決定 `DisplayDeviceInfo.state` 的值
- 考慮兩個不同的 state 變量是否需要同步更新
