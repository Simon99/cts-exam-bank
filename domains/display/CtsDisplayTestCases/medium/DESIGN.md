# CtsDisplayTestCases - 中級題設計方案（5 題）

## 設計原則
- 中級：需要自己添加額外 log 才能定位
- Log 中能看到 fail 現象，但 root cause 不在 log 直接指向的位置
- 需要在相關函數中加 log 追踪數據流向

---

## Q001 - 亮度 Slider 事件丟失
**觸發測試：** `testBrightnessSliderTracking`
**fail 現象：** `assertEquals(1, newEvents.size())` 失敗，events 數量為 0
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java` → `handleBrightnessChanged()`
**Bug 內容：** 在 `handleBrightnessChanged` 中修改判斷條件，使得 `userInitiated` 為 true 時提前 return（應該是 false 時 return）
**為什麼需要加 log：** CTS log 只顯示 events 為空，不會告訴你是哪裡吞了事件。需要在 BrightnessTracker 的 notifyBrightnessChanged → handleBrightnessChanged 鏈路中加 log 追踪
**考察：** 理解 brightness event 收集機制 → 在正確位置加 log → 發現條件判斷反轉

---

## Q002 - Display Mode 切換後回報舊模式
**觸發測試：** `testModeSwitchOnPrimaryDisplay`
**fail 現象：** mode switch 後，getMode() 返回的還是舊 mode
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
**Bug 內容：** 在更新 display info 時，mode 切換完成但 `mOverrideDisplayInfo` 沒有正確更新（cache 了舊值）
**為什麼需要加 log：** log 中只能看到測試期待的 mode 和實際 mode 不同，但 DisplayManagerService 層面的 mode 設定流程正常（設定成功了），問題在 info 回傳路徑。需要加 log 在 LogicalDisplay.getDisplayInfoLocked 追踪
**考察：** 理解 mode 設定和查詢是不同路徑 → 在中間層加 log 確認數據

---

## Q003 - HDR User Disabled Types 過濾失效
**觸發測試：** `testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes`
**fail 現象：** 設定了 user disabled HDR types 後，getHdrCapabilities 仍返回被禁用的 type
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
**Bug 內容：** 在 `setUserDisabledHdrTypesInternal` 中，成功存儲了 disabled types，但在 `getHdrCapabilities` 的過濾邏輯中使用了錯誤的比較（`!=` 寫成 `==`）
**為什麼需要加 log：** 設定 API 成功返回（沒有 error），查詢結果卻不對。需要在過濾邏輯處加 log 看每個 type 的判斷結果
**考察：** 理解 set/get 是不同方法 → 追踪 get 路徑中的過濾邏輯

---

## Q004 - BrightnessConfiguration 曲線套用錯誤
**觸發測試：** `testSetGetSimpleCurve` / `testSetAndGetBrightnessConfiguration`
**fail 現象：** setBrightnessConfiguration 後，getBrightnessConfiguration 返回的曲線值不一致
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayPowerController.java` → `setBrightnessConfiguration()`
**Bug 內容：** 在保存 configuration 時，把 lux 和 nits 陣列的順序弄反
**為什麼需要加 log：** fail log 顯示 curve 不匹配但不顯示具體是哪個值錯。需要在 set 和 get 路徑都加 log 對比數據
**考察：** 理解 BrightnessConfiguration 的存取路徑 → 加 log 對比 set/get 的值

---

## Q005 - Virtual Display 建立後 HDR 能力異常
**觸發測試：** `testHdrApiMethods` (VirtualDisplayTest)
**fail 現象：** VirtualDisplay 的 getHdrCapabilities 返回值異常
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`
**Bug 內容：** 在建立 VirtualDisplayDevice 時，HDR capabilities 的初始化邏輯錯誤（把 supported types 設成了 empty 但 luminance 設了值，造成不一致）
**為什麼需要加 log：** CTS 只顯示最終 assertion 失敗，不會顯示 VirtualDisplay 的建立過程。需要在 VirtualDisplayAdapter 加 log 追踪初始化值
**考察：** 理解 VirtualDisplay 的建立流程 → 定位到 Adapter 層的初始化問題

---

## 備註
中級題共同特點：
1. CTS fail log 能看到現象（assert 失敗）但不能直接定位 root cause
2. 問題發生在「設定」和「查詢」的中間環節
3. 需要理解數據流向，在關鍵節點加 log 才能找到問題
4. 修復可能涉及 1-2 個檔案
