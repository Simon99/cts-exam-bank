# CtsDisplayTestCases - 高級題設計方案（5 題）

## 設計原則
- 高級：錯誤的業務邏輯橫跨至少三個檔案
- A 檔案打出 log → A 呼叫 B 的函數 → B 呼叫 C 的函數 → 問題在 C
- 需要追踪完整調用鏈才能定位

---

## Q001 - Display Mode 偏好設定後 Reboot 失效
**觸發測試：** `testSetUserPreferredDisplayModeForSpecificDisplay` (DefaultDisplayModeTest)
**fail 現象：** setUserPreferredDisplayMode 設定成功，但 getUserPreferredDisplayMode 回傳 null
**調用鏈：**
- A: `DisplayManagerService.java` → `setUserPreferredDisplayModeInternal()` 打 log，看起來設定成功
- B: `DisplayDevice.java` → `setUserPreferredDisplayModeLocked()` 被呼叫，將 mode 存到 device
- C: `PersistentDataStore.java` → `setUserPreferredResolution()` / `setUserPreferredRefreshRate()` — 這裡的序列化邏輯有 bug（例如 refresh rate 存成 int 丟失小數點）
**Bug 在 C：** PersistentDataStore 序列化時把 float 的 refreshRate 強轉 int，導致讀回來的值不匹配
**考察：** 從 DMS log → 追到 DisplayDevice → 追到 PersistentDataStore 的序列化

---

## Q002 - 自動亮度配置切換用戶後丟失
**觸發測試：** `testSetAndGetPerDisplay` (BrightnessTest)
**fail 現象：** 多用戶場景下，切回原用戶後 brightness configuration 丟失
**調用鏈：**
- A: `DisplayManagerService.java` → `onSwitchUser()` 打 log，顯示用戶切換觸發
- B: `DisplayPowerController.java` → `setBrightnessConfiguration()` 被呼叫載入新用戶配置
- C: `BrightnessMappingStrategy.java` → `setBrightnessConfiguration()` 內部清理前一個配置時，因為比較邏輯錯誤把原用戶的配置也清掉了
**Bug 在 C：** BrightnessMappingStrategy 在清理 short-term model 時用了全局清理而非 per-user 清理
**考察：** 用戶切換 → DMS 層正常 → DPC 層正常 → BrightnessMappingStrategy 的清理邏輯有問題

---

## Q003 - Display Event 回調缺失
**觸發測試：** `testDisplayEvents` (DisplayEventTest)
**fail 現象：** 監聽 DisplayListener 後，display 變化事件沒有被回調
**調用鏈：**
- A: `DisplayManagerService.java` → `handleDisplayDeviceChanged()` 偵測到 display 變化，打 log
- B: `LogicalDisplayMapper.java` → `updateLogicalDisplays()` 處理映射更新
- C: `DisplayManagerService.java` 的內部類 `CallbackRecord` → `notifyDisplayEventAsync()` — 在判斷是否需要通知時，diff 檢查邏輯 (DIFF_OTHER) 遺漏了某些變更類型
**Bug 在 C：** notifyDisplayEventAsync 中的 diff bitmask 檢查遺漏了 DIFF_OTHER，導致特定類型變更不觸發回調
**考察：** 事件產生正常 → 映射更新正常 → 通知派發的 diff 過濾有問題

---

## Q004 - Color Mode 設定無效
**觸發測試：** `testGetSupportWideColorGamut_displayIsWideColorGamut` 
**fail 現象：** Display 報告支持 wide color gamut 但實際 supportedWideColorGamuts 為空
**調用鏈：**
- A: `DisplayManagerService.java` → `configureColorModeLocked()` 收到 color mode 設定請求
- B: `LogicalDisplay.java` → `setRequestedColorModeLocked()` 更新 requested color mode
- C: `DisplayDevice.java` → `setRequestedColorModeLocked()` → 底層 `LocalDisplayAdapter.java` → `requestColorMode()` — 這裡把 WIDE 模式映射到了錯誤的 HAL 常數
**Bug 在 C：** LocalDisplayAdapter 把 COLOR_MODE_WIDE_COLOR_GAMUT 映射成了 COLOR_MODE_DEFAULT 的 HAL 值
**考察：** DMS 設定正常 → LogicalDisplay 記錄正常 → 底層 Adapter 的映射錯誤

---

## Q005 - Overlay Display 的 Metrics 計算錯誤
**觸發測試：** `testGetMetrics` (針對 secondary display)
**fail 現象：** Overlay display 的 density/size metrics 不符預期
**調用鏈：**
- A: `DisplayManagerService.java` → `configureDisplayLocked()` 配置顯示參數
- B: `LogicalDisplay.java` → `configureDisplayLocked()` 計算 display info
- C: `OverlayDisplayAdapter.java` → `OverlayDisplayDevice` 的 `getDisplayDeviceInfoLocked()` — density 計算時除法順序錯誤導致精度丟失（先做整數除法再乘）
**Bug 在 C：** OverlayDisplayDevice 的 density 計算用了 `(width / defaultWidth) * defaultDensity` 而非 `width * defaultDensity / defaultWidth`，整數除法先執行導致結果偏差
**考察：** DMS 層配置正常 → LogicalDisplay 轉發正常 → OverlayDisplayAdapter 的計算精度問題

---

## 備註
高級題共同特點：
1. Log 出現在 A 檔案，問題在 C 檔案
2. A → B → C 的調用鏈需要完整追踪
3. A 和 B 的行為看起來都正常，需要深入到 C 才能發現問題
4. 修復在 C 檔案，但需要理解整個鏈路確認沒有 side effect
5. 涉及 3 個以上檔案的理解
