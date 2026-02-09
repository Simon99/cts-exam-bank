# Q003 解答

## 問題根因

Bug 位於 `VirtualDisplayAdapter.java` 的 `VirtualDisplayDevice.getDisplayDeviceInfoLocked()` 方法中。

### 錯誤代碼
```java
mInfo.renderFrameRate = REFRESH_RATE;  // 使用固定的 60Hz
```

### 正確代碼
```java
mInfo.renderFrameRate = mMode.getRefreshRate();  // 使用 Mode 中的實際刷新率
```

## 問題分析

### RefreshRate 的完整傳遞路徑

1. **應用程式層**
   - `VirtualDisplayConfig.Builder.setRequestedRefreshRate(30.0f)` 設置請求的刷新率
   - `VirtualDisplayConfig.getRequestedRefreshRate()` 返回 30.0f

2. **設備適配器層**
   - `VirtualDisplayAdapter.VirtualDisplayDevice` 構造函數儲存 `mRequestedRefreshRate = 30.0f`
   - `getRefreshRate()` 方法返回 `mRequestedRefreshRate`（如果不為 0）
   - `createMode(mWidth, mHeight, getRefreshRate())` 創建 Mode，刷新率為 30Hz

3. **設備資訊層**（問題所在）
   - `mInfo.modeId = mMode.getModeId()` ✓ 正確
   - `mInfo.supportedModes = new Display.Mode[] { mMode }` ✓ 正確
   - `mInfo.renderFrameRate = REFRESH_RATE` ✗ **錯誤！使用了 60Hz 常數**

4. **邏輯顯示層**
   - `LogicalDisplay.updateLocked()` 複製 `deviceInfo.renderFrameRate` 到 `mBaseDisplayInfo.renderFrameRate`

5. **API 層**
   - `DisplayInfo.getRefreshRate()` 返回 `renderFrameRate`（60Hz，錯誤值）
   - `Display.getRefreshRate()` 返回 60Hz 而非預期的 30Hz

### 為什麼這是跨檔案問題

這個 bug 需要理解 3 個檔案的交互：

1. **VirtualDisplayConfig.java** - 定義 API 層配置結構
2. **VirtualDisplayAdapter.java** - 處理配置並創建 DisplayDeviceInfo
3. **DisplayDeviceInfo.java** - 儲存設備資訊並傳遞給 LogicalDisplay

問題不是單純的「值設錯了」，而是需要理解：
- `requestedRefreshRate` 如何從 Config 傳遞到 Adapter
- `Mode` 如何根據 refreshRate 創建
- `DisplayDeviceInfo` 的各個欄位如何從不同來源填充
- 為什麼 `modeId` 和 `supportedModes` 使用 `mMode`，但 `renderFrameRate` 使用了 `REFRESH_RATE`

## 修復方式

將 `mInfo.renderFrameRate = REFRESH_RATE;` 改為 `mInfo.renderFrameRate = mMode.getRefreshRate();`

這確保 `renderFrameRate` 與 `supportedModes` 中的 Mode 保持一致。

## 驗證命令

```bash
# 運行 CTS 測試
adb shell am instrument -w -r \
    -e class android.display.cts.VirtualDisplayTest#testVirtualDisplayWithRequestedRefreshRate \
    android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

## 學習重點

1. **數據一致性**：同一組相關數據（如 Mode 和 renderFrameRate）應該從相同來源獲取
2. **常數陷阱**：使用類別常數時要確認它是否適用於所有情況
3. **跨層追蹤**：理解數據如何從 API 層傳遞到底層實現
