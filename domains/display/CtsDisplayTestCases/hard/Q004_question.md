# Hard Q004: Virtual Display Resize 事件丟失

## 問題描述

您正在調試一個 Android 系統問題。當應用程式調用 `VirtualDisplay.resize()` 改變虛擬顯示的尺寸時，`DisplayManager.DisplayListener.onDisplayChanged()` callback 沒有被觸發。

## CTS 測試結果

```bash
adb shell am instrument -w -r \
  -e class android.display.cts.DisplayEventTest \
  android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

測試失敗，錯誤訊息：
```
junit.framework.AssertionFailedError: Timeout waiting for DISPLAY_CHANGED event
Expected: DISPLAY_CHANGED for displayId=2
Actual: No event received within 10 seconds
```

## 重現步驟

1. 創建一個 VirtualDisplay
2. 註冊 DisplayListener
3. 調用 `VirtualDisplay.resize(newWidth, newHeight, newDensity)`
4. 等待 `onDisplayChanged()` callback
5. **問題：callback 永遠不會被觸發**

## 技術背景

Virtual Display 的尺寸變更需要經過以下傳播路徑：

1. `VirtualDisplayAdapter.resizeLocked()` - 更新 DisplayDevice 資訊
2. `DisplayDeviceRepository` - 將變更通知給 Listener
3. `LogicalDisplayMapper.updateLogicalDisplaysLocked()` - 比較 DisplayInfo 變化並發送事件
4. `DisplayManagerService.handleLogicalDisplayChangedLocked()` - 發送事件到已註冊的 callbacks

在 `LogicalDisplayMapper` 中，系統使用布林條件來判斷是否需要發送 `DISPLAY_CHANGED` 事件。這個判斷涉及：
- `wasDirty` - display 是否被標記為需要更新
- `mTempDisplayInfo.equals(newDisplayInfo)` - 新舊 DisplayInfo 是否相同

## 相關元件

- `VirtualDisplayAdapter` - 處理虛擬顯示的創建和變更
- `LogicalDisplayMapper` - 管理邏輯顯示並發送事件（**重點關注**）
- `LogicalDisplay` - 封裝顯示的配置資訊，包含 `mDirty` 標記
- `DisplayManagerService` - 接收事件並通知應用程式

## 任務

找出為什麼 `DISPLAY_CHANGED` 事件在 resize 後沒有被發送，並修復這個問題。

**提示**：問題可能在於布林邏輯的使用。仔細閱讀條件判斷的運算符。

## 時間限制

45 分鐘
