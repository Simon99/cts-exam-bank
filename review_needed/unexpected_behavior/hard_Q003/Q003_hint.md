# Q003 提示

## 提示 1（基礎）
追蹤 `Display.getRefreshRate()` 的返回值來源。最終它讀取的是 `DisplayInfo.renderFrameRate`。

## 提示 2（中級）
檢查 `VirtualDisplayDevice.getDisplayDeviceInfoLocked()` 方法中如何設置 `DisplayDeviceInfo` 的各個欄位。比較 `modeId`、`supportedModes` 和 `renderFrameRate` 的值來源。

## 提示 3（進階）
`REFRESH_RATE` 是一個類別常數，代表默認的 60Hz。`mMode.getRefreshRate()` 返回的是根據 `requestedRefreshRate` 創建的實際 Mode 的刷新率。這兩個值在什麼情況下會不同？

## 關鍵洞察
問題在於 `renderFrameRate` 的設置沒有使用與 `supportedModes` 相同的值來源。`supportedModes` 使用 `mMode`（正確），但 `renderFrameRate` 可能使用了其他值。
