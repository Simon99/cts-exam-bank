# CTS 題庫進度追蹤

**最後更新**: 2026-02-11 12:43 GMT+8

## 當前階段

- Phase A：建立注入點分布列表 ✅
- Phase B：題目產生 ✅
- **Phase C：Dry Run 驗證** ✅

### 題庫狀態
- **總題數：473 題**（15 領域）
- **Dry Run 成功率：100%**（473/473）
- 詳見 [DOMAIN_STATUS.md](DOMAIN_STATUS.md)

---

## Phase B 進度 - 題目產生

### ✅ 已完成模組

| 模組 | 已產生題目 | 目標 | 完成率 | 路徑 |
|------|-----------|------|--------|------|
| **camera** | 51 | 27 | 189% ✅ | `questions/camera/` |
| **display** | 28 | 52 | 54% 🔄 | `questions/display/` |
| **總計** | **79** | 79 | — | |

### 🔄 進行中

- **display** — 目前有 ~15 個 sub-agents 並行產題中

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

### 📋 待處理模組

| 優先級 | 模組 | CTS 路徑 | 備註 |
|--------|------|----------|------|
| 中 | app | `cts/tests/app/` | Activity、Service 等 |
| 中 | accessibilityservice | `cts/tests/accessibilityservice/` | 無障礙服務 |
| 中 | admin | `cts/tests/admin/` | 設備管理 |
| 低 | backup | `cts/tests/backup/` | 備份 |
| 低 | atv | `cts/tests/atv/` | Android TV |

---

## 更新歷史

### 2026-02-10 17:55
- **Phase B 開始！**
- camera 模組完成 51 題（超額完成）
- display 模組進行中，已完成 28 題

### 2026-02-10 22:35
- 新增 5 個模組的注入點列表：sensor, AlarmManager, vibrator, input, security
- 總注入點數達 586 個

---

## 流程文件

- `QUESTION_GENERATION_FLOW.md` (v1.4.0) — 三階段流程定義
- `REVIEW_CRITERIA.md` — 審查標準

---

## 2026-02-10 結構說明

### 題目來源差異

| 領域 | questions/ | domains/ | 總計 | 說明 |
|------|------------|----------|------|------|
| camera | 51 | 33 | 84 | 兩套並存 |
| display | 44 | 30 | 74 | 兩套並存 |
| 其他 13 領域 | 0 | 30 | 30 | 僅新格式 |

### 原因
- `questions/` 是早期格式（CAM-001, DIS-001 命名）
- `domains/` 是標準化格式（easy/medium/hard 子目錄，Q001 命名）
- camera 和 display 是最早開發的領域，保留了兩套

### 檔案結構對照

**舊格式 (questions/)**
```
questions/camera/CAM-001_xxx/
├── meta.json
├── question.md
├── answer.md
└── patch.diff
```

**新格式 (domains/)**
```
domains/camera/easy/
├── Q001_question.md
├── Q001_answer.md
├── Q001_meta.json
└── Q001_bug.patch
```

### 待決定
- [ ] 是否合併兩套格式
- [ ] 是否統一命名規範
