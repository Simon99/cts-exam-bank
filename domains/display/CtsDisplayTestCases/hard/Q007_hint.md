# Q007 提示

## 提示 1：數據流追蹤
追蹤 `supportedModes` 陣列從 VirtualDisplayDevice 到 DisplayInfo 的完整路徑：
- VirtualDisplayDevice.getDisplayDeviceInfoLocked() 創建新 Mode
- LogicalDisplay.updateLocked() 複製 deviceInfo 到 mBaseDisplayInfo
- DisplayInfo 最終被應用層獲取

## 提示 2：關鍵變量
注意以下變量的生命週期和更新時機：
- `mPrimaryDisplayDeviceInfo` - 上一次的設備信息（可能是陳舊的）
- `deviceInfo` - 當前的設備信息（包含新的 mode）
- `mBaseDisplayInfo.supportedModes` - 被複製到 DisplayInfo 的 modes 陣列

## 提示 3：Bug 位置
Bug 分佈在三個檔案中：
1. **VirtualDisplayAdapter.java** - `resizeLocked()` 中的操作順序
2. **LogicalDisplay.java** - `updateLocked()` 中複製 supportedModes 的來源
3. **DisplayDeviceInfo.java** - `copyFrom()` 中的條件複製邏輯

## 提示 4：根本原因
當 VirtualDisplay resize 時：
- 創建了新的 Mode（modeId = 2）
- 但 `supportedModes` 被從錯誤的來源複製（仍然只包含 modeId = 1）
- 導致 `findMode(2)` 在 `supportedModes` 中找不到對應的 mode

## 提示 5：修復方向
確保：
1. `supportedModes` 總是從當前的 `deviceInfo` 複製，而不是從緩存的 `mPrimaryDisplayDeviceInfo`
2. `DisplayDeviceInfo.copyFrom()` 無條件複製 `supportedModes`
3. 操作順序正確：先清除緩存，再發送更新請求
