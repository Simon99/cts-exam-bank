# Step 5：清理提示 — 檢查流程與標準

> **版本**: v2.0  
> **更新日期**: 2026-02-23  
> **教訓來源**: DIS-H006 交付時漏檢 meta.json、question.md 等檔案

---

## 核心原則

**面試者拿到的材料，不應該讓他不用分析代碼就能猜到答案。**

題庫保留完整資訊（給出題者/驗證者），Step 5 產出「面試者版本」。

---

## 檢查流程

```
Step 5.1  刪除解答檔案
Step 5.2  清理 meta.json
Step 5.3  重寫 question.md（面試者版本）
Step 5.4  審查 question_info.md
Step 5.5  檢查 cts_results/
Step 5.6  最終確認（面試者視角審讀）
```

---

## Step 5.1：刪除解答檔案

必須刪除：

| 檔案 | 原因 |
|------|------|
| `answer.md` | 直接解答 |
| `bug.patch` | 顯示修改內容 |
| `*.orig` | 原始代碼，可 diff 對比 |

---

## Step 5.2：清理 meta.json

### 必須刪除的欄位

| 欄位 | 原因 |
|------|------|
| `bug_description` | 直接說明 bug |
| `root_cause` | 直接說明原因 |
| `fix_complexity` | 直接說明修復方法 |
| `affected_methods` | 指出方法名 |
| `hints` | 解題提示 |
| `injection_point` | 內部追蹤用 |
| `injection_type` | 暴露 bug 類型 |

### 必須審查的欄位

| 欄位 | 檢查重點 |
|------|---------|
| `tags` | 移除暴露類型的 tag（如 `condition-inversion`, `off-by-one`, `null-check`） |
| `affected_files` | 若題目不應指出檔案則刪除 |

### 可保留的欄位

```
id, title（若為通用標題）, domain, difficulty, 
cts_test, cts_module, estimated_time_minutes, 
skills_tested, created_at, verified, verification_date
```

---

## Step 5.3：重寫 question.md（面試者版本）

### 禁止出現

| 類型 | 範例 |
|------|------|
| 檔案名稱 | `DisplayManagerService.java` |
| 檔案路徑 | `frameworks/base/services/core/...` |
| 類別名稱 | `PendingCallback` |
| 方法名稱 | `addDisplayEvent()` |
| 行號 | 「約 3666-3677 行」 |
| Bug 類型描述 | 「去重邏輯」「條件判斷」 |
| 直接提示 | 「檢查判斷條件是否完整」 |

### 允許出現

| 類型 | 範例 |
|------|------|
| CTS 測試名稱 | `DisplayEventTest#testDisplayEvents` |
| 失敗症狀 | 「部分 display 的事件通知丟失」 |
| 觸發條件 | 「多 display 場景」「cached apps」 |
| 背景知識 | Display Event 類型、Cached App 機制 |

### 面試者版本模板

```markdown
# CTS 題目：[通用標題，不暴露 bug 類型]

**難度**: [Easy/Medium/Hard]
**預計時間**: XX 分鐘
**CTS 測試**: `[完整測試名稱]`

---

## 問題描述

[描述症狀，不描述原因]

測試失敗的症狀：
- [可觀察到的行為 1]
- [可觀察到的行為 2]
- [觸發條件]

---

## 你的任務

1. 從 CTS 測試追蹤，找出導致測試失敗的 bug
2. 說明 bug 的根本原因和觸發條件
3. 提供修復方案

---

## 相關背景知識

[僅提供理解問題所需的概念，不暗示位置]

---

## 答題格式

## Bug 位置
[指出具體的程式碼位置和有問題的邏輯]

## 根本原因
[解釋為什麼這段代碼會導致測試失敗]

## 修復方案
[提供具體的修復代碼]
```

---

## Step 5.4：審查 question_info.md

檢查標題和描述是否暴露 bug 類型：

| ❌ 不可接受 | ✅ 可接受 |
|------------|----------|
| `Event Deduplication Logic Error` | `Display Event Delivery Issue` |
| `Condition Inversion Bug` | `CTS Test Failure` |
| `涉及 event-deduplication` | `涉及 display 事件處理` |

---

## Step 5.5：檢查 cts_results/

確認沒有包含：
- 帶有 diff 輸出的 log
- 指向具體行號的 stack trace
- 任何可推斷修改位置的資訊

通常 CTS 結果可保留（面試者也會跑 CTS），但需審查內容。

---

## Step 5.6：最終確認

**面試者視角審讀：**

1. 拿到這份材料，我能不看代碼就猜到 bug 在哪嗎？
2. 有沒有任何「捷徑」讓我跳過追蹤過程？
3. 我必須從 CTS 測試開始追才能找到問題嗎？

如果答案是「能猜到」或「有捷徑」，繼續清理。

---

## Checklist

```
[ ] answer.md 已刪除
[ ] bug.patch 已刪除
[ ] *.orig 已刪除
[ ] meta.json 敏感欄位已清除
[ ] meta.json tags 已審查
[ ] question.md 無檔案/類別/方法/行號
[ ] question.md 無 bug 類型描述
[ ] question.md 無直接提示
[ ] question_info.md 標題不暴露
[ ] cts_results/ 已審查
[ ] 面試者視角審讀通過
```
