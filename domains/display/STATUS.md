# CTS Display 題庫狀態總覽

**更新時間**: 2026-02-09 19:20
**版本**: v1.0

---

## 📊 總體統計

| 難度 | 總數 | ✅ 驗證通過 | 🔧 待驗證 | ⚠️ 問題 | ❌ 需重設計 |
|------|------|------------|----------|---------|------------|
| Easy | 4 | 3 | 1 | 0 | 0 |
| Medium | 10 | 6 | 1 | 1 | 2 |
| Hard | 10 | 2 | 4 | 2 | 2 |
| **合計** | **24** | **11** | **6** | **3** | **4** |

**完成率**: 11/24 (46%) 完全驗證通過

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

| 題號 | 測試 | 狀態 | Bug 類型 |
|------|------|------|----------|
| Q001 | testBrightnessSliderTracking | ❓ 未驗證 | 亮度事件丟失 |
| Q002 | testModeSwitchOnPrimaryDisplay | ✅ VERIFIED | Mode 切換回報舊模式 |
| Q003 | testGetHdrCapabilities...FilteredHdrTypes | ✅ VERIFIED | HDR 過濾失效 |
| Q004 | testSetGetSimpleCurve | ⏭ SKIPPED | 設備不支持自動亮度 |
| Q005 | testHdrApiMethods | ✅ VERIFIED | VirtualDisplay HDR 異常 |
| Q006 | testFlags | ❌ FAILED | Bug 不觸發測試失敗 |
| Q007 | testGetHdrCapabilities...FilteredHdrTypes | ✅ VERIFIED | HDR filter operator 錯誤 |
| Q008 | testUntrustedSysDecorVirtualDisplay | ✅ VERIFIED | VirtualDisplay flag 問題 |
| Q009 | testActiveModeIsSupportedModes | ❌ FAILED | Bug 反而讓測試更容易過 |
| Q010 | testPrivatePresentationVirtualDisplay | ✅ VERIFIED | VirtualDisplay 呈現問題 |

**Medium 完成率**: 6/10 (60%)

---

## Hard (困難) - 10 題

| 題號 | 測試 | 狀態 | Bug 類型 |
|------|------|------|----------|
| Q001 | testModeSwitchOnTvDisplay | ⏭ SKIPPED | 需要 Android TV |
| Q002 | - | ❌ BOOTLOOP | Bug 太嚴重 |
| Q003 | - | 🔧 待驗證 | RefreshRate 問題 |
| Q004 | - | 🔧 待驗證 | Resize 事件丟失 |
| Q005 | testGetHdrCapabilities...FilteredHdrTypes | ✅ VERIFIED | HDR User Disabled Types |
| Q006 | RefreshRateTest | ⚠ INVALID | 測試類不存在 |
| Q007 | DisplayTest | ✅ **VERIFIED** | **系統崩潰** ✓ |
| Q008 | - | ❌ NEEDS_REDESIGN | Patch 無效 |
| Q009 | DefaultDisplayModeTest | 🔧 待驗證 | equals() 遺漏 |
| Q010 | DefaultDisplayModeTest | 🔧 待驗證 | Parcel 順序錯誤 |

**Hard 完成率**: 2/10 (20%)

---

## 🔧 待處理事項

### 高優先級（設備恢復後）
- [ ] Hard Q003, Q004 - 運行 CTS 驗證
- [ ] Hard Q009, Q010 - 運行 CTS 驗證

### 中優先級
- [ ] Hard Q008 - 重新設計 patch（目前只有註釋）
- [ ] Medium Q006, Q009 - 調整 bug 或找正確測試
- [ ] Easy Q002 - 補充驗證

### 低優先級
- [ ] Hard Q002 - 重新設計更輕微的 bug
- [ ] Hard Q006 - 找到正確測試類或移除

---

## 📁 目錄結構

```
domains/display/CtsDisplayTestCases/
├── easy/           # 初級題 (Q001-Q004)
├── medium/         # 中級題 (Q001-Q010)
├── hard/           # 困難題 (Q001-Q010)
│   └── validation_summary.md  # Hard 題詳細驗證報告
└── STATUS.md       # 本文件
```

---

## 🛠 設備狀態

| 設備 | 序號 | 狀態 |
|------|------|------|
| Pixel 7 (左) | 27161FDH20031X | 🔴 fastboot 卡住 |
| Pixel 7 (右) | 2B231FDH200B4Z | 🔴 fastboot 卡住 |

**問題**: USB 通訊異常，fastboot devices 可見但命令無回應
**解決方案**: 需要物理操作（長按電源鍵重啟）

---

## 📝 經驗教訓

1. **Bug 設計需謹慎** - 太嚴重會導致 bootloop，太輕微測試抓不到
2. **驗證測試存在性** - 先確認 CTS 測試類/方法存在
3. **理解代碼路徑** - 需要深入理解 forceUpdate 等機制
4. **Patch 格式** - 確保 patch 有實際代碼變更，不只是註釋
