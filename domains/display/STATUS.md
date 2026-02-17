# CTS Display 題庫狀態總覽

**更新時間**: 2026-02-17 17:50
**版本**: v1.1

---

## 📊 總體統計

| 難度 | 總數 | ✅ 驗證通過 | 🔧 待驗證 | ⚠️ Issue | ❌ Unfixable |
|------|------|------------|----------|---------|--------------|
| Easy | 10 | 3 | 7 | 0 | 0 |
| Medium | 10 | 1 | 5 | 4 | 0 |
| Hard | 10 | 7 | 0 | 2 | 1 |
| **合計** | **30** | **11** | **12** | **6** | **1** |

**完成率**: 11/30 (37%) 完全驗證通過

---

## Easy (初級) - 4 題

| 題號 | 測試 | 狀態 | Bug 類型 |
|------|------|------|----------|
| Q001 | testDefaultDisplayHdrCapability | ✅ VERIFIED | HDR 亮度值交換 |
| Q002 | testGetSupportedModesOnDefaultDisplay | ❓ 未驗證 | Display 模式列表為空 |
| Q003 | testGetPreferredWideGamutColorSpace | ✅ VERIFIED | Wide Color Gamut 判斷反轉 |
| Q004 | testConfigureBrightnessPermission | ✅ VERIFIED | 亮度權限檢查缺失 |

**Easy 完成率**: 3/4 (75%)

---

## Medium (中級) - 10 題

| 題號 | 測試 | 狀態 | Bug 類型 | 備註 |
|------|------|------|----------|------|
| Q001 | testBrightnessSliderTracking | ⚠️ Issue | 亮度事件丟失 | BrightnessTest 被跳過 |
| Q002 | testModeSwitchOnPrimaryDisplay | ⚠️ Issue | Mode 切換回報舊模式 | BrightnessTest 被跳過 |
| Q003 | testGetHdrCapabilities...FilteredHdrTypes | ⚠️ Issue | HDR 過濾失效 | BrightnessTest 被跳過 |
| Q004 | testSetGetSimpleCurve | ⚠️ Issue | 設備不支持自動亮度 | BrightnessTest 被跳過 |
| Q005 | VirtualDisplayTest | ✅ **VERIFIED** | VirtualDisplay HDR 異常 | 2026-02-17 驗證通過 |
| Q006 | VirtualDisplayTest | ❓ 待驗證 | VirtualDisplay null 處理 | |
| Q007 | VirtualDisplayTest | ❓ 待驗證 | Trusted Display 權限檢查 | |
| Q008 | DisplayTest | ❓ 待驗證 | Display Override 條件反轉 | |
| Q009 | HdrConversionEnabledTest | ❓ 待驗證 | HDR 轉換模式覆蓋 | |
| Q010 | DisplayTest | ❓ 待驗證 | HDR 禁用設定清除 | |

**Medium 完成率**: 1/10 (10%)
**Medium Q001-Q004 Issue**: BrightnessTest 需要 BRIGHTNESS_SLIDER_USAGE 權限，AOSP 缺失該權限導致測試被跳過

---

## Hard (困難) - 10 題

| 題號 | 測試 | 狀態 | Bug 類型 | Issue |
|------|------|------|----------|-------|
| Q001 | testModeSwitchOnPrimaryDisplay | ✅ VERIFIED | RefreshRate 精度錯誤 | Issue_0001 Resolved |
| Q002 | - | ⚠️ Issue | 系統崩潰 | Issue_0002 重新設計中 |
| Q003 | testModeSwitchOnTvDisplay | ✅ VERIFIED | Mode 切換被拒絕 | Issue_0003 Resolved |
| Q004 | testAlternativeRefreshRates | ✅ VERIFIED | 對稱性錯誤 | Issue_0004 Resolved |
| Q005 | - | ❌ Unfixable | 無法設計可被偵測的 bug | Issue_0005 Unfixable |
| Q006 | testDisplayChangeEvent | ✅ VERIFIED | Event deduplication 錯誤 | Issue_0006 Resolved |
| Q007 | testUnregisterCallback | ✅ VERIFIED | Callback 清理問題 | Issue_0007 Resolved |
| Q008 | testSetBrightnessConfiguration | ✅ VERIFIED | 權限檢查繞過 | Issue_0008 Resolved |
| Q009 | - | ⚠️ Issue | 測試需要 Android TV | Issue_0009 待處理 |
| Q010 | - | ⚠️ Issue | 測試需要 Android TV | Issue_0010 待處理 |

**Hard 完成率**: 7/10 (70%)

---

## 🔧 待處理事項

### 高優先級
- [ ] Medium Q001-Q004 — 生成 Issue（BrightnessTest 被跳過）
- [ ] Hard Q002 — 重新設計（避免系統崩潰）

### 中優先級
- [ ] Hard Q009, Q010 — 考慮移至 Android TV 專用題庫或標記為 TV-only
- [ ] Easy Q002 — 補充驗證

### 低優先級
- [ ] Hard Q005 — 已標記為 Unfixable，無需處理

---

## 📁 目錄結構

```
domains/display/
├── easy/           # 初級題 (Q001-Q004)
├── medium/         # 中級題 (Q001-Q010)
├── hard/           # 困難題 (Q001-Q010)
└── STATUS.md       # 本文件
```

---

## 🛠 設備狀態

| 設備 | 序號 | 狀態 |
|------|------|------|
| Pixel 7 (左) | 27161FDH20031X | ✅ 正常運行 |
| Pixel 7 (右) | 2B231FDH200B4Z | ✅ 正常運行 |

---

## 📅 最近驗證記錄

| 日期 | 題目 | 結果 | 備註 |
|------|------|------|------|
| 2026-02-17 | Medium Q005 | ✅ PASS | VirtualDisplayTest: 2P/8F |
| 2026-02-13 | Hard H006-H010 | 5/5 處理 | 3 通過, 2 需 TV |
| 2026-02-12 | Hard H001-H005 | 5/5 處理 | 4 通過, 1 Unfixable |

---

## 📝 經驗教訓

1. **Bug 設計需謹慎** - 太嚴重會導致 bootloop，太輕微測試抓不到
2. **驗證測試存在性** - 先確認 CTS 測試類/方法存在
3. **權限依賴** - 某些測試需要特定權限（如 BRIGHTNESS_SLIDER_USAGE）
4. **設備限制** - 某些測試需要特定設備類型（如 Android TV）
5. **Patch 格式** - 確保 patch 有實際代碼變更，不只是註釋
