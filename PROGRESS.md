# CTS 題庫進度追蹤

**最後更新**: 2026-02-17 17:50 GMT+8

## 當前階段

- Phase A：建立注入點分布列表 ✅
- Phase B：題目產生 ✅
- Phase C：Dry Run 驗證 ✅
- **Phase C：真機驗證** 🔄 進行中

### 題庫狀態
- **總題數：473 題**（15 領域）
- **Dry Run 成功率：100%**（473/473）
- 詳見 [DOMAIN_STATUS.md](DOMAIN_STATUS.md)

---

## Phase C 真機驗證進度

### Display 模組驗證狀態

#### Display Hard (H001-H010)

| 題目 | 驗證結果 | Issue | 說明 |
|------|----------|-------|------|
| H001 | ✅ PASS | Issue_0001 Resolved | RefreshRate 精度錯誤 |
| H002 | ⚠️ Issue | Issue_0002 重新設計中 | 系統崩潰 |
| H003 | ✅ PASS | Issue_0003 Resolved | Mode 切換被拒絕 |
| H004 | ✅ PASS | Issue_0004 Resolved | 對稱性錯誤 |
| H005 | ❌ Unfixable | Issue_0005 | 無法設計可偵測 bug |
| H006 | ✅ PASS | Issue_0006 Resolved | Event deduplication |
| H007 | ✅ PASS | Issue_0007 Resolved | Callback 清理 |
| H008 | ✅ PASS | Issue_0008 Resolved | 權限檢查繞過 |
| H009 | ⚠️ Issue | Issue_0009 | 需要 Android TV |
| H010 | ⚠️ Issue | Issue_0010 | 需要 Android TV |

**Display Hard 統計：7 Resolved / 1 Unfixable / 2 需 TV**

#### Display Medium (Q001-Q010)

| 題目 | 驗證結果 | 說明 |
|------|----------|------|
| Q001-Q004 | ⚠️ Issue | BrightnessTest 被跳過（AOSP 缺 BRIGHTNESS_SLIDER_USAGE 權限）|
| **Q005** | ✅ **PASS** | **2026-02-17 驗證通過** (2P/8F) |
| Q006-Q010 | ✅ PASS | 早期驗證通過 |

**Display Medium 統計：6/10 通過 / 4 待處理（BrightnessTest）**

#### Display Easy (Q001-Q004)

| 題目 | 驗證結果 | 說明 |
|------|----------|------|
| Q001 | ✅ PASS | HDR 亮度值交換 |
| Q002 | ❓ 未驗證 | Display 模式列表為空 |
| Q003 | ✅ PASS | Wide Color Gamut 判斷反轉 |
| Q004 | ✅ PASS | 亮度權限檢查缺失 |

**Display Easy 統計：3/4 通過**

---

### Issue 列表

| Issue | 題目 | 類型 | 狀態 | 日期 |
|-------|------|------|------|------|
| Issue_0001 | DIS-H001 | Bug/CTS 不匹配 | ✅ Resolved | 2026-02-12 |
| Issue_0002 | DIS-H002 | 系統崩潰 | 🔄 重新設計中 | - |
| Issue_0003 | DIS-H003 | Bug 未被偵測 | ✅ Resolved | 2026-02-12 |
| Issue_0004 | DIS-H004 | 會崩潰 | ✅ Resolved | 2026-02-12 |
| Issue_0005 | DIS-H005 | 無法設計 | ❌ Unfixable | 2026-02-12 |
| Issue_0006 | DIS-H006 | Bug 調整 | ✅ Resolved | 2026-02-13 |
| Issue_0007 | DIS-H007 | Bug 調整 | ✅ Resolved | 2026-02-13 |
| Issue_0008 | DIS-H008 | Bug 調整 | ✅ Resolved | 2026-02-13 |
| Issue_0009 | DIS-H009 | 需要 Android TV | ⚠️ 待處理 | - |
| Issue_0010 | DIS-H010 | 需要 Android TV | ⚠️ 待處理 | - |
| Issue_0011 | DIS-M001~M004 | BrightnessTest 被跳過 | ⚠️ 待建立 | - |

---

## Phase B 進度 - 題目產生

### ✅ 已完成模組

| 模組 | 已產生題目 | 目標 | 完成率 | 路徑 |
|------|-----------|------|--------|------|
| **camera** | 51 | 27 | 189% ✅ | `questions/camera/` |
| **display** | 28 | 52 | 54% 🔄 | `questions/display/` |
| **總計** | **79** | 79 | — | |

### 📋 待處理

按優先級排序：
1. media (52 注入點)
2. location (47 注入點)
3. JobScheduler (78 注入點)
4. net (33 注入點)
5. sensor (42 注入點)
6. AlarmManager (56 注入點)

---

## Phase A 進度 - 注入點分布列表

### ✅ 已完成模組（14 個）

| 模組 | 注入點 | Easy | Medium | Hard | 檔案路徑 |
|------|--------|------|--------|------|----------|
| camera | 27 | 10 | 11 | 6 | `injection-points/tests/camera.md` |
| media | 52 | 18 | 22 | 12 | `injection-points/tests/media.md` |
| location | 47 | 18 | 19 | 10 | `injection-points/tests/location.md` |
| net | 33 | 13 | 12 | 8 | `injection-points/tests/net.md` |
| filesystem | 28 | 10 | 12 | 6 | `injection-points/tests/filesystem.md` |
| display | 52 | 18 | 24 | 10 | `injection-points/tests/display.md` |
| JobScheduler | 78 | 28 | 32 | 18 | `injection-points/tests/JobScheduler.md` |
| graphics | 32 | 12 | 14 | 6 | `injection-points/hostsidetests/graphics.md` |
| acceleration | 18 | 8 | 7 | 3 | `injection-points/tests/acceleration.md` |
| sensor | 42 | 16 | 17 | 9 | `injection-points/tests/sensor.md` |
| AlarmManager | 56 | 18 | 24 | 14 | `injection-points/tests/AlarmManager.md` |
| vibrator | 38 | 14 | 16 | 8 | `injection-points/tests/vibrator.md` |
| input | 48 | 18 | 20 | 10 | `injection-points/tests/input.md` |
| security | 35 | 12 | 15 | 8 | `injection-points/tests/security.md` |
| **總計** | **586** | 213 | 245 | 128 | |

**難度分布**: Easy 36% / Medium 42% / Hard 22%

---

## 更新歷史

### 2026-02-17 17:50
- **Display Medium Q005 真機驗證通過** ✅
  - CTS 結果：2 PASSED / 8 FAILED
  - VirtualDisplayTest 成功檢測到 bug
- 更新 Display Hard Issue 狀態：7 Resolved, 1 Unfixable
- 確認 Medium Q001-Q004 需生成 Issue（BrightnessTest 被跳過）

### 2026-02-13 06:10
- **Display Hard H006-H010 真機驗證完成**
- H006, H008 驗證通過
- H007, H009 Bug 未被偵測 → 新增 Issue_0006, Issue_0007
- H010 測試需要 Android TV → 新增 Issue_0008

### 2026-02-12
- Display Hard H001-H005 Issue 處理
- Issue_0001, 0003, 0004 已解決
- Issue_0005 標記為 Unfixable

### 2026-02-10 17:55
- **Phase B 開始！**
- camera 模組完成 51 題（超額完成）
- display 模組進行中，已完成 28 題

---

## 流程文件

- `QUESTION_GENERATION_FLOW.md` (v1.4.0) — 三階段流程定義
- `REVIEW_CRITERIA.md` — 審查標準
- `domains/display/STATUS.md` — Display 模組詳細狀態
