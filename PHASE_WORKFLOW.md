# CTS 題庫三階段工作流程

**版本**: v1.0.0  
**建立日期**: 2026-02-10  
**更新時間**: 2026-02-10 20:27 GMT+8

---

## 流程總覽

```
Phase A: 注入點分析    →    Phase B: 題目產生    →    Phase C: 實機驗證
   (一次性)                   (批量產出)                (逐題驗證)
```

---

## Phase A: 注入點分析

**目標**: 從 CTS 測試和 AOSP 源碼找出可注入 bug 的程式碼位置

### 輸入
- CTS 測試源碼: `cts/tests/<領域>/`
- AOSP 實作源碼: `frameworks/base/...` 等

### 步驟

| Step | 動作 | 說明 |
|------|------|------|
| A1 | CTS 測試分析 | 列出該領域所有測試類別、驗證的功能點 |
| A2 | AOSP 源碼掃描 | 找出對應 CTS 測試的實作程式碼 |
| A3 | 交叉比對 | 產生注入點清單，標註難度和 bug 類型 |

### 輸出
```
injection-points/tests/<領域>.md
```

每個注入點包含:
- ID (例: SEN-001)
- 函數/區塊名稱
- 行號範圍
- 注入類型 (COND/BOUND/RES/STATE/CALC/STR/SYNC/ERR)
- 難度評估 (Easy/Medium/Hard)
- 對應 CTS 測試

### 狀態
✅ **15 領域已完成** (683 個注入點)

---

## Phase B: 題目產生

**目標**: 根據注入點產生完整題目包

### 輸入
- 注入點分布列表 (`injection-points/tests/<領域>.md`)
- AOSP 源碼 (`~/develop_claw/aosp-sandbox-1/`)

### 步驟

| Step | 動作 | 說明 |
|------|------|------|
| B1 | 挑選注入點 | 從列表選擇要出題的點，考慮難度分布 |
| B2 | 設計 Bug | 設計具體 bug（條件反轉、邊界錯誤等）|
| B3 | 產生 Patch | 寫出可 apply 的 unified diff |
| B4 | 撰寫題目 | 四選一題目 + 答案解析 |
| B5 | Dry-run 驗證 | `patch --dry-run -p1 < bug.patch` |

### 輸出
```
domains/<領域>/<難度>/
├── Q001_question.md   # 四選一題目
├── Q001_answer.md     # 答案與解析
├── Q001_meta.json     # 元資料
└── Q001_bug.patch     # Bug 注入 patch
```

### 難度定義
| 難度 | 涉及檔案 | 複雜度 | 時間預估 |
|------|---------|--------|---------|
| Easy | 1 檔案 | 單一明顯錯誤 | 10-15 分鐘 |
| Medium | 1-2 檔案 | 跨函數邏輯 | 20-30 分鐘 |
| Hard | ≥3 檔案 | 跨模組架構 | 30-45 分鐘 |

### 狀態
✅ **15 領域已完成** (473 題)

---

## Phase C: 實機驗證

**目標**: 確認 bug patch 能讓 CTS 測試失敗

### 輸入
- Bug patch (`Q001_bug.patch`)
- AOSP 源碼 (`~/develop_claw/aosp-sandbox-2/`)
- Pixel 7 設備

### 步驟

| Step | 動作 | 命令/說明 |
|------|------|----------|
| C1 | 套用 Patch | `patch -p1 < bug.patch` |
| C2 | 編譯 AOSP | `m -j$(nproc)` |
| C3 | 刷機 | `flash-clean.sh <serial>` + 刷入新 image |
| C4 | 執行 CTS | `atest <CtsTestModule>` 或完整 CTS |
| C5 | 確認失敗 | 驗證預期的測試 FAIL |
| C6 | 收集 Log | 保存 fail log 作為題目佐證 |
| C7 | 還原 | `patch -R -p1 < bug.patch` |

### 輸出
- 更新 `meta.json`: `"verified": true`
- 可選: 保存 CTS fail log 到題目目錄

### 設備資訊
| 設備 | Serial | 用途 |
|------|--------|------|
| Pixel 7 #1 | 27161FDH20031X | 主要測試機 |
| Pixel 7 #2 | 2B231FDH200B4Z | 備用 |

### AOSP 環境
| 目錄 | 用途 |
|------|------|
| `aosp-sandbox-1/` | 乾淨版本（參考用）|
| `aosp-sandbox-2/` | Bug 實驗用 |
| `aosp-images/clean-panther-14/` | 乾淨 image 備份 |

### 狀態
⏳ **待執行** (473 題待驗證)

---

## 注入類型標籤

| 標籤 | 說明 | 範例 |
|------|------|------|
| COND | 條件判斷 | `if (x == y)` → `if (x != y)` |
| BOUND | 邊界檢查 | `i < len` → `i <= len` |
| RES | 資源管理 | 漏掉 `close()` |
| STATE | 狀態轉換 | flag 設錯、狀態機錯誤 |
| CALC | 數值計算 | 運算符錯誤、單位轉換 |
| STR | 字串處理 | `equals()` vs `==` |
| SYNC | 同步問題 | 缺少鎖、競態條件 |
| ERR | 錯誤處理 | 例外處理不當 |

---

## 執行原則

### 並行處理
- **一題一 Agent**: 批量任務拆分成個別 sub-agent
- **60 秒紅線**: 主 session 超過 60 秒無響應要改用 sub-agent

### 品質控制
- 所有 patch 必須通過 `--dry-run` 驗證
- 每題必備 4 個檔案: question.md, answer.md, meta.json, bug.patch
- Phase C 驗證後才標記 `verified: true`

---

**文件位置**: `~/develop_claw/cts-exam-bank/PHASE_WORKFLOW.md`
