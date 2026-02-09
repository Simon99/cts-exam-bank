# Hard Q001-Q010 CTS 驗證摘要

## 驗證日期
2026-02-09 (最終更新)

## 驗證設備
- Pixel 7 (2B231FDH200B4Z)
- Pixel 7 (27161FDH20031X)

## 驗證環境
- AOSP sandbox-2: ~/develop_claw/aosp-sandbox-2/
- 乾淨 image: ~/aosp-images/clean-panther-14/

## 驗證結果總覽

| 題號 | 狀態 | 說明 |
|------|------|------|
| Q001 | ⏭ SKIPPED | 需要 Android TV 設備，Pixel 7 被跳過（符合預期）|
| Q002 | ❌ BOOTLOOP | Bug 導致系統無法啟動，題目設計需調整 |
| Q003 | 🔧 REDESIGNED | Bug 位置已修正，待驗證 |
| Q004 | 🔧 REDESIGNED | Bug 重新設計為 \|\| → && 邏輯錯誤，待驗證 |
| Q005 | ✅ VERIFIED | Bug 導致測試失敗，符合預期設計 ✓ |
| Q006 | ⚠ INVALID | 指定的測試類 RefreshRateTest 不存在 |
| Q007 | ✅ **VERIFIED** | **Bug 導致系統崩潰，符合預期** ✓ |
| Q008 | ❌ NEEDS_REDESIGN | Patch 只有註釋無代碼變更，測試方法不存在 |
| Q009 | 🔧 REDESIGNED | 改為移除 defaultModeId 比較，待驗證 |
| Q010 | 🔧 REDESIGNED | 改為交換 defaultModeId/userPreferredModeId，待驗證 |

## 統計
- **✅ 完全驗證**: 2 (Q005, Q007)
- **🔧 重設計待驗證**: 4 (Q003, Q004, Q009, Q010)
- **⏭ 跳過**: 1 (Q001 - 需要 Android TV)
- **⚠ 無效**: 1 (Q006 - 測試類不存在)
- **❌ 需重設計**: 2 (Q002 - bootloop, Q008 - patch 無效)

## 詳細結果

### Q001: Display Mode 偏好設定持久化失敗
- **狀態**: ⏭ SKIPPED（符合預期）
- **原因**: 測試需要 Android TV 設備

### Q002: Display Mode 傳遞鏈數據丟失
- **狀態**: ❌ BOOTLOOP
- **原因**: Bug 太嚴重導致系統無法啟動
- **建議**: 修改 bug 使其更輕微

### Q003: VirtualDisplay RequestedRefreshRate 問題
- **狀態**: 🔧 REDESIGNED (待驗證)
- **問題**: 原 bug 修改的 `renderFrameRate` 欄位不被測試使用
- **修復**: 重新設計 bug 位置到 `getRefreshRate()` 方法

### Q004: Virtual Display Resize 事件丟失
- **狀態**: 🔧 REDESIGNED (待驗證)
- **修復方案**: 改為邏輯運算符錯誤（|| → &&）
- **新 bug**: `wasDirty || !equals` 改為 `wasDirty && !equals`

### Q005: HDR User Disabled Types 同步問題 ✓
- **狀態**: ✅ VERIFIED
- **測試**: testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes
- **結果**: FAILED（預期 2 個 HDR，實際 4 個）
- **結論**: 題目設計正確 ✓

### Q006: Brightness Zone Thermal Refresh Rate 問題
- **狀態**: ⚠ INVALID
- **原因**: RefreshRateTest 測試類不存在
- **建議**: 找到正確的測試類或移除題目

### Q007: VirtualDisplay Resize Mode 查找失敗 ✓
- **狀態**: ✅ **VERIFIED** (2026-02-09)
- **測試結果**:
  - VirtualDisplayTest: 10 tests PASS
  - DisplayTest: **SYSTEM CRASHED** (符合預期)
- **Bug 機制**: resize 後新 modeId 不存在於 stale supportedModes，findMode() 失敗導致崩潰
- **結論**: 題目設計正確 ✓

### Q008: VirtualDisplay State 同步問題
- **狀態**: ❌ NEEDS_REDESIGN (2026-02-09)
- **問題**:
  1. Q008_bug.patch 只有註釋，無代碼變更
  2. 測試方法 `testVirtualDisplayStateConsistency` 不存在於 CTS
- **建議**: 創建真正的 bug patch 或改為分析類題目

### Q009: DisplayInfo equals defaultModeId 比較遺漏
- **狀態**: 🔧 REDESIGNED (待驗證)
- **新設計**: 移除 `defaultModeId == other.defaultModeId` 比較
- **目標測試**: DefaultDisplayModeTest

### Q010: DisplayInfo Parcel 順序錯誤
- **狀態**: 🔧 REDESIGNED (待驗證)
- **新設計**: 交換 writeToParcel 中 defaultModeId 和 userPreferredModeId 順序
- **目標測試**: DefaultDisplayModeTest

## 設備狀態 (2026-02-09 19:00)
- 兩台 Pixel 7 卡在 fastboot 模式
- USB 通訊異常：fastboot devices 可見但命令無回應
- 需要物理操作恢復

## 後續工作

### 設備恢復後
1. Q003, Q004, Q009, Q010 - 運行 CTS 驗證
2. Q008 - 重新設計 patch

### 不需要設備
3. Q002 - 重新設計更輕微的 bug
4. Q006 - 找到正確測試類或移除
5. Q008 - 重新設計或改為分析類題目
