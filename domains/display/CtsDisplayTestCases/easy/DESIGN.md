# CtsDisplayTestCases - 初級題設計方案（5 題）

## 設計原則
- 初級：讀 log 就能定位問題
- Bug 位置明確，log 中有直接的 error/exception 信息
- 修改通常在單一檔案內

---

## Q001 - HDR Capabilities 亮度值異常
**觸發測試：** `testDefaultDisplayHdrCapability`
**fail 現象：** `assertTrue(cap.getDesiredMinLuminance() <= cap.getDesiredMaxAverageLuminance())` 失敗
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java` 或 `LogicalDisplay.java`
**Bug 內容：** 在組裝 HdrCapabilities 時，把 minLuminance 和 maxAverageLuminance 的值交換
**log 線索：** CTS log 會直接顯示 assertion 失敗，並且 `dumpsys display` 可以看到亮度值異常
**考察：** 讀 CTS fail log → 看到 luminance 值順序不對 → 搜索源碼中組裝 HdrCapabilities 的地方

---

## Q002 - Display 模式列表為空
**觸發測試：** `testGetSupportedModesOnDefaultDisplay`
**fail 現象：** `supportedModes` 陣列長度為 0 或缺少當前 active mode
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
**Bug 內容：** 在 `getDisplayInfoInternal` 中，返回 DisplayInfo 前篩掉了某些 mode（例如加了一個錯誤的 filter 條件）
**log 線索：** CTS log 顯示 modes 數量不符預期，logcat 中 DisplayManagerService 有相關 debug log
**考察：** 讀 fail log → 觀察 modes 異常 → 搜索 getSupportedModes 調用鏈

---

## Q003 - Wide Color Gamut 判斷反轉
**觸發測試：** `testGetPreferredWideGamutColorSpace`
**fail 現象：** display.isWideColorGamut() 返回 true 但 getPreferredWideGamutColorSpace() 返回 null（或反過來）
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java` → `getPreferredWideGamutColorSpaceIdInternal()`
**Bug 內容：** 把判斷條件取反（`!isWideColorGamut` → `isWideColorGamut`）或回傳了錯誤的 colorSpaceId
**log 線索：** assertion fail 直接指出 isWideColorGamut 和 colorSpace 不匹配
**考察：** 讀 log 看 assert 信息 → 定位 getPreferredWideGamutColorSpace 的實現

---

## Q004 - 亮度權限檢查缺失
**觸發測試：** `testConfigureBrightnessPermission`
**fail 現象：** 測試預期拋出 SecurityException 但沒有拋出（`fail()` 被執行）
**埋 bug 位置：** `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
**Bug 內容：** 在 `setBrightnessConfigurationForDisplay` 方法中註釋掉或跳過了權限檢查（`checkPermission`）
**log 線索：** CTS log 顯示 `fail()` - 沒有捕獲到 SecurityException；logcat 中缺少權限 deny log
**考察：** 讀 fail log → 理解測試邏輯是驗證權限保護 → 搜索權限檢查代碼

---

## Q005 - 系統屬性導致 Framebuffer 尺寸限制
**觸發測試：** `testRestrictedFramebufferSize`
**fail 現象：** `assertEquals("", width)` 失敗，非 TV 裝置出現了 framebuffer 尺寸限制
**埋 bug 位置：** `device/google/panther/` 下的某個 `.prop` 或 `device.mk` 文件
**Bug 內容：** 添加了 `ro.surface_flinger.max_graphics_width=1920` 系統屬性
**log 線索：** assertion 直接顯示 expected="" actual="1920"
**考察：** 讀 log 看具體 property name → `getprop` 或 grep 源碼找到設定位置

---

## 備註
所有初級題的共同特點：
1. CTS fail log 中有明確的 assertion message
2. 問題原因可以通過閱讀 log + 基本的 grep/搜索定位
3. 不需要加額外 log 就能找到 root cause
4. 修復通常是單行或幾行的改動
