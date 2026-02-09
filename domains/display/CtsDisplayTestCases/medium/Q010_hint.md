# Hard Q003 提示

## 提示 1（輕度）
Flag 從 `DisplayManager` API 層傳遞到 `DisplayDeviceInfo` 需要經過轉換。查看 `VirtualDisplayAdapter` 中處理各種 flag 的方式。

## 提示 2（中度）
對比 `VIRTUAL_DISPLAY_FLAG_SECURE` 和 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 的處理方式。它們都需要設置對應的 `DisplayDeviceInfo.FLAG_*` 值。

## 提示 3（重度）
在 `getDisplayDeviceInfoLocked()` 方法中，查看第 494 行附近的 if 區塊。條件檢查存在，但實際的 flag 設置操作缺失了。
