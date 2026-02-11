# display 注入點分布列表

**CTS 路徑**: `cts/tests/tests/display/`
**更新時間**: 2025-06-08

## 概覽
- 總注入點數：52
- 按難度分布：Easy(18) / Medium(24) / Hard(10)
- 涵蓋測試類別：BrightnessTest, DisplayTest, DisplayManagerTest, VirtualDisplayTest, HdrConversionEnabledTest, DefaultDisplayModeTest, DisplayEventTest, VirtualDisplayConfigTest

## 對應 AOSP 源碼路徑
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
- `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java`
- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`
- `frameworks/base/services/core/java/com/android/server/display/BrightnessMappingStrategy.java`

---

## 注入點清單

### 1. Brightness Management（亮度管理）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-001 | BrightnessTracker.java | getEvents() | 266-300 | COND, BOUND | Easy | BrightnessTest#testBrightnessSliderTracking |
| DIS-002 | BrightnessTracker.java | recordBrightnessEvent() | ~350-420 | STATE, ERR | Medium | BrightnessTest#testBrightnessSliderTracking |
| DIS-003 | BrightnessTracker.java | assertValidLuxData() validation | ~180-210 | BOUND, CALC | Easy | BrightnessTest#testBrightnessSliderTracking |
| DIS-004 | DisplayManagerService.java | setBrightnessConfiguration() | ~2900-2950 | COND, ERR | Medium | BrightnessTest#testSetGetSimpleCurve |
| DIS-005 | DisplayManagerService.java | getBrightnessConfiguration() | ~2850-2900 | COND, STATE | Easy | BrightnessTest#testGetDefaultCurve |
| DIS-006 | DisplayManagerService.java | getDefaultBrightnessConfiguration() | ~2800-2850 | ERR, STATE | Easy | BrightnessTest#testGetDefaultCurve |
| DIS-007 | BrightnessMappingStrategy.java | getBrightness() | ~200-250 | CALC, BOUND | Medium | BrightnessTest#testSliderEventsReflectCurves |
| DIS-008 | DisplayManagerService.java | setBrightnessConfigurationForDisplay() | ~2950-3000 | COND, STATE | Medium | BrightnessTest#testSetAndGetPerDisplay |

### 2. Virtual Display（虛擬顯示器）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-009 | VirtualDisplayAdapter.java | createVirtualDisplayLocked() | 107-155 | COND, ERR | Medium | VirtualDisplayTest#testPrivateVirtualDisplay |
| DIS-010 | VirtualDisplayAdapter.java | VirtualDisplayDevice constructor | 275-305 | STATE, BOUND | Easy | VirtualDisplayTest#testPrivateVirtualDisplay |
| DIS-011 | VirtualDisplayAdapter.java | setSurfaceLocked() | 180-195 | STATE, RES | Easy | VirtualDisplayTest#testPrivateVirtualDisplayWithDynamicSurface |
| DIS-012 | VirtualDisplayAdapter.java | resizeLocked() | 165-178 | CALC, BOUND | Easy | VirtualDisplayTest#testVirtualDisplayRotatesWithContent |
| DIS-013 | DisplayManagerService.java | createVirtualDisplayInternal() | 1500-1750 | COND, ERR | Hard | VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay |
| DIS-014 | DisplayManagerService.java | releaseVirtualDisplayLocked() | ~1800-1850 | RES, STATE | Medium | VirtualDisplayTest#testPrivateVirtualDisplay |
| DIS-015 | VirtualDisplayAdapter.java | generateDisplayUniqueId() | 215-222 | STR, CALC | Easy | VirtualDisplayTest#testPrivateVirtualDisplay |
| DIS-016 | DisplayManagerService.java | VIRTUAL_DISPLAY_FLAG validation | 1500-1620 | COND, ERR | Medium | VirtualDisplayTest#testTrustedVirtualDisplay |
| DIS-017 | VirtualDisplayAdapter.java | destroyLocked() | ~340-360 | RES, STATE | Medium | VirtualDisplayTest#testPrivateVirtualDisplay |
| DIS-018 | DisplayManagerService.java | validateVirtualDisplayFlags() | ~1550-1600 | COND, BOUND | Medium | VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay |

### 3. Display Properties（顯示器屬性）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-019 | LogicalDisplay.java | getDisplayInfoLocked() | 225-235 | STATE, COND | Easy | DisplayTest#testGetDisplayAttrs |
| DIS-020 | LogicalDisplay.java | updateLocked() | ~350-450 | STATE, CALC | Hard | DisplayTest#testMode |
| DIS-021 | DisplayDeviceInfo.java | FLAG constants handling | ~50-100 | COND, BOUND | Easy | DisplayTest#testFlags |
| DIS-022 | LogicalDisplay.java | setDisplayInfoOverrideFromWindowManagerLocked() | ~295-320 | STATE, COND | Medium | DisplayTest#testGetMetrics |
| DIS-023 | DisplayManagerService.java | getDisplayInfo() | ~2100-2150 | COND, ERR | Easy | DisplayTest#testDefaultDisplay |
| DIS-024 | LogicalDisplay.java | getNonOverrideDisplayInfoLocked() | 243-245 | STATE | Easy | DisplayTest#testGetMetrics |

### 4. HDR Capabilities（HDR 能力）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-025 | DisplayManagerService.java | getSupportedHdrOutputTypes() | ~3100-3130 | BOUND, COND | Easy | HdrConversionEnabledTest#testGetSupportedHdrOutputTypes |
| DIS-026 | DisplayManagerService.java | setHdrConversionMode() | ~3050-3100 | STATE, COND | Medium | HdrConversionEnabledTest#testSetHdrConversionMode |
| DIS-027 | DisplayManagerService.java | getHdrConversionModeSetting() | ~3030-3050 | STATE | Easy | HdrConversionEnabledTest#testSetHdrConversionMode |
| DIS-028 | DisplayManagerService.java | setUserDisabledHdrTypes() | ~3000-3030 | STATE, BOUND | Medium | DisplayTest#testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings |
| DIS-029 | DisplayManagerService.java | setAreUserDisabledHdrTypesAllowed() | ~2980-3000 | STATE, COND | Easy | DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes |
| DIS-030 | DisplayManagerService.java | overrideHdrTypes() | ~3130-3160 | STATE, BOUND | Medium | DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreAllowedReturnsNonFilteredHdrTypes |
| DIS-031 | LogicalDisplay.java | mUserDisabledHdrTypes filtering | ~180-200 | COND, BOUND | Medium | DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes |

### 5. Display Mode Switching（顯示模式切換）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-032 | DisplayManagerService.java | setGlobalUserPreferredDisplayMode() | ~3200-3250 | STATE, COND | Medium | DefaultDisplayModeTest#testSetAndClearUserPreferredDisplayModeGeneratesDisplayChangedEvents |
| DIS-033 | DisplayManagerService.java | clearGlobalUserPreferredDisplayMode() | ~3250-3280 | STATE | Easy | DefaultDisplayModeTest#testGetUserPreferredDisplayMode |
| DIS-034 | DisplayManagerService.java | getGlobalUserPreferredDisplayMode() | ~3180-3200 | STATE | Easy | DefaultDisplayModeTest#testGetUserPreferredDisplayMode |
| DIS-035 | LogicalDisplay.java | setDesiredDisplayModeSpecsLocked() | ~420-460 | STATE, COND | Hard | DisplayTest#testModeSwitchOnPrimaryDisplay |
| DIS-036 | DisplayManagerService.java | setRefreshRateSwitchingType() | ~3300-3330 | STATE, BOUND | Medium | DisplayTest#testModeSwitchOnPrimaryDisplay |
| DIS-037 | LogicalDisplay.java | getSupportedModes() calculation | ~500-550 | CALC, BOUND | Hard | DisplayTest#testGetSupportedModesOnDefaultDisplay |
| DIS-038 | DisplayManagerService.java | getAlternativeRefreshRates() | ~2200-2250 | CALC, BOUND | Hard | DisplayTest#testGetSupportedModesOnDefaultDisplay |

### 6. Display Events & Callbacks（顯示事件與回調）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-039 | DisplayManagerService.java | registerDisplayListener() | ~2000-2050 | STATE, ERR | Medium | DisplayEventTest#testDisplayEvents |
| DIS-040 | DisplayManagerService.java | deliverDisplayEvent() | ~4200-4280 | COND, STATE | Hard | DisplayEventTest#testDisplayEvents |
| DIS-041 | DisplayManagerService.java | CallbackRecord handling | ~4100-4150 | STATE, SYNC | Hard | DisplayEventTest#testDisplayEvents |
| DIS-042 | DisplayManagerService.java | sendDisplayEventLocked() | ~4150-4200 | COND, STATE | Medium | DisplayTest#testRefreshRateSwitchOnSecondaryDisplay |
| DIS-043 | DisplayManagerService.java | handleDisplayDeviceAdded() | ~3700-3750 | STATE, ERR | Medium | DisplayTest#testSecondaryDisplay |
| DIS-044 | DisplayManagerService.java | handleDisplayDeviceRemoved() | ~3750-3800 | STATE, RES | Medium | VirtualDisplayTest#testPrivateVirtualDisplay |

### 7. Display Configuration（顯示配置）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-045 | VirtualDisplayAdapter.java | VirtualDisplayConfig validation | 107-130 | BOUND, ERR | Easy | VirtualDisplayConfigTest#parcelAndUnparcel_matches |
| DIS-046 | VirtualDisplayAdapter.java | getRefreshRate() | ~320-330 | CALC, BOUND | Easy | VirtualDisplayTest#testVirtualDisplayWithRequestedRefreshRate |
| DIS-047 | DisplayManagerService.java | shouldAlwaysRespectAppRequestedMode() | ~3330-3360 | STATE, COND | Medium | DisplayTest#testModeSwitchOnPrimaryDisplay |
| DIS-048 | LogicalDisplay.java | mRequestedColorMode handling | ~160-180 | STATE, COND | Medium | DisplayTest#testGetPreferredWideGamutColorSpace |
| DIS-049 | VirtualDisplayAdapter.java | display categories handling | ~290-310 | STR, BOUND | Easy | VirtualDisplayConfigTest#virtualDisplayConfig_onlyRequiredFields |

### 8. Permission & Security（權限與安全）

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| DIS-050 | DisplayManagerService.java | checkCallingPermission() for brightness | ~2860-2880 | COND, ERR | Medium | BrightnessTest#testConfigureBrightnessPermission |
| DIS-051 | DisplayManagerService.java | checkCallingPermission() for slider usage | ~2830-2850 | COND, ERR | Medium | BrightnessTest#testSliderUsagePermission |
| DIS-052 | DisplayManagerService.java | ADD_TRUSTED_DISPLAY permission check | 1560-1580 | COND, ERR | Hard | VirtualDisplayTest#testTrustedVirtualDisplay |

---

## 注入類型說明

| 類型 | 說明 | 常見 Bug 模式 |
|------|------|--------------|
| COND | 條件判斷 | if/else 邏輯反轉、比較運算符錯誤 |
| BOUND | 邊界檢查 | 陣列索引越界、null 檢查遺漏、範圍驗證錯誤 |
| RES | 資源管理 | 資源未釋放、重複釋放 |
| STATE | 狀態轉換 | 狀態機錯誤、flag 設置錯誤 |
| CALC | 數值計算 | 運算符錯誤、單位轉換錯誤 |
| STR | 字串處理 | 字串比較錯誤、格式化錯誤 |
| SYNC | 同步問題 | 競態條件、鎖使用錯誤 |
| ERR | 錯誤處理 | 例外處理不當、回傳值檢查遺漏 |

---

## 難度分布統計

| 難度 | 數量 | 佔比 |
|------|------|------|
| Easy | 18 | 34.6% |
| Medium | 24 | 46.2% |
| Hard | 10 | 19.2% |
| **總計** | **52** | **100%** |

---

## CTS 測試涵蓋度

| CTS Test Class | 注入點數量 |
|----------------|-----------|
| BrightnessTest | 10 |
| DisplayTest | 16 |
| VirtualDisplayTest | 12 |
| DisplayManagerTest | 2 |
| HdrConversionEnabledTest | 4 |
| DefaultDisplayModeTest | 4 |
| DisplayEventTest | 3 |
| VirtualDisplayConfigTest | 3 |

---

## 建議優先注入區域

### 高價值區域（覆蓋多個 CTS 測試）
1. **DisplayManagerService.java** - 核心服務，影響幾乎所有測試
2. **VirtualDisplayAdapter.java** - VirtualDisplay 相關測試的主要來源
3. **BrightnessTracker.java** - 亮度追蹤測試的主要來源

### 易於注入區域（改動小、效果明確）
1. 條件判斷反轉（COND 類型）
2. 邊界檢查移除（BOUND 類型）
3. 狀態設置錯誤（STATE 類型）

---

**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/display.md`
**版本**: v1.0.0
**最後更新**: 2025-06-08
