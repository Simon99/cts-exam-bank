# CTS Hard Q007: VirtualDisplay Resize 後 Mode 查找失敗

## 難度：Hard (多檔案交互)

## 問題描述

當一個 **VirtualDisplay** 被 resize 後，應用嘗試獲取 Display 的當前 mode 時拋出 `IllegalStateException`。

## 復現步驟

1. 創建一個 VirtualDisplay（1920x1080，60Hz）
2. 獲取 Display 對象並確認 `display.getMode()` 正常工作
3. 調用 `virtualDisplay.resize(1280, 720, 240)` 改變 VirtualDisplay 的尺寸
4. 等待 DISPLAY_CHANGED 事件
5. 嘗試調用 `display.getMode()`
6. **預期：** 返回新的 mode（1280x720）
7. **實際：** 拋出 `IllegalStateException: Unable to locate mode id=2`

## 涉及的 CTS 測試

```
adb shell am instrument -w -e class android.display.cts.VirtualDisplayTest#testVirtualDisplayResizeMode \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

## 測試失敗日誌

```
java.lang.IllegalStateException: Unable to locate mode id=2, 
    supportedModes=[Mode{id=1, width=1920, height=1080, refreshRate=60.0, ...}]
    at android.view.DisplayInfo.findMode(DisplayInfo.java:683)
    at android.view.DisplayInfo.getMode(DisplayInfo.java:668)
    at android.view.Display.getMode(Display.java:1131)
    at android.display.cts.VirtualDisplayTest.testVirtualDisplayResizeMode(VirtualDisplayTest.java:XXX)
```

## 架構說明

VirtualDisplay resize 的數據流：

```
VirtualDisplay.resize(width, height, densityDpi)
    ↓
VirtualDisplayAdapter.resizeVirtualDisplayLocked()
    ↓
VirtualDisplayDevice.resizeLocked()
    ↓ 創建新 Mode（新 modeId）
    ↓ 設置 mInfo = null
    ↓
sendDisplayDeviceEventLocked(DISPLAY_DEVICE_EVENT_CHANGED)
    ↓
LogicalDisplay.updateLocked()
    ↓ 複製 DisplayDeviceInfo 到 mBaseDisplayInfo
    ↓
DisplayInfo.copyFrom() 或直接賦值
    ↓
應用調用 Display.getMode()
    ↓
DisplayInfo.findMode(modeId)  ← 可能找不到對應的 mode
```

## 你的任務

1. 分析 VirtualDisplay resize 後 mode 信息在多個檔案間的傳遞流程
2. 找出為什麼 `modeId` 和 `supportedModes` 會不同步
3. 這個 bug 涉及至少 3 個檔案的交互
4. 提供修復方案

## 相關源代碼路徑

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`

## 調試提示

- 追蹤 `modeId` 從 VirtualDisplayDevice 到 DisplayInfo 的完整路徑
- 注意 `supportedModes` 陣列是如何被複製的
- 比較 `LogicalDisplay.updateLocked()` 中 modeId 和 supportedModes 的更新順序
- 思考當 DisplayDeviceInfo.copyFrom() 和 Arrays.copyOf() 的交互
