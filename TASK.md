# CTS 題庫開發任務

**更新時間**: 2026-02-09 23:05
**版本**: v1.0

---

## 階段定義

### 第一階段：設計階段
- 讀源代碼
- 設計 patch（埋 bug）
- 創建題目檔案（question.md、answer.md、bug.patch、meta.json）

### 第二階段：驗證階段
- 套用 patch 到 AOSP
- 編譯修改的模組
- 執行 CTS 測試
- 收集 log 確認 bug 有效

---

## 難度定義

| 難度 | 定位難度 | 修改範圍 |
|------|----------|----------|
| **Easy** | 讀 CTS fail log 就能定位 | 單一檔案 |
| **Medium** | 需要加額外 log 追蹤 | 1-2 個檔案 |
| **Hard** | 需要理解多個檔案交互 | ≥3 個檔案 |

---

## 題目規模

| 領域 | Easy | Medium | Hard | 總計 |
|------|------|--------|------|------|
| display | 10 | 10 | 10 | 30 |
| media | 10 | 10 | 10 | 30 |
| gpu | 10 | 10 | 10 | 30 |
| camera | 10 | 10 | 10 | 30 |
| framework | 10 | 10 | 10 | 30 |
| filesystem | 10 | 10 | 10 | 30 |
| net | 10 | 10 | 10 | 30 |
| app | 10 | 10 | 10 | 30 |
| location | 10 | 10 | 10 | 30 |
| jobscheduler | 10 | 10 | 10 | 30 |
| **總計** | **100** | **100** | **100** | **300** |

---

## 每題檔案結構

```
domains/<領域>/<難度>/
├── Q001_question.md    # 題目描述（CTS fail 現象）
├── Q001_answer.md      # 答案解析（root cause + 修復方式）
├── Q001_bug.patch      # 埋 bug 的 patch
├── Q001_fix.patch      # 修復 bug 的 patch（可選）
├── Q001_meta.json      # 元數據
└── Q001_results/       # 驗證結果（第二階段產出）
    ├── cts_output.txt
    └── summary.txt
```

### meta.json 格式
```json
{
  "id": "Q001",
  "difficulty": "easy|medium|hard",
  "domain": "display",
  "title": "題目標題",
  "ctsTest": "android.display.cts.DisplayTest#testMethod",
  "ctsModule": "CtsDisplayTestCases",
  "bugType": "logic_error|race_condition|null_check|...",
  "affectedFiles": ["path/to/file1.java", "path/to/file2.java"],
  "tags": ["hdr", "virtual_display", ...],
  "verification": {
    "status": "pending|verified|failed|skipped",
    "date": null,
    "device": null
  }
}
```

---

## 進度追蹤

### 第一階段（設計）

| 領域 | 狀態 | Easy | Medium | Hard | 備註 |
|------|------|------|--------|------|------|
| display | ✅ 完成 | 4/10 | 10/10 | 10/10 | 已有 24 題 |
| media | 🔄 進行中 | - | - | - | sub-agent |
| gpu | 🔄 進行中 | - | - | - | sub-agent |
| camera | 🔄 進行中 | - | - | - | sub-agent |
| framework | 🔄 進行中 | - | - | - | sub-agent |
| filesystem | 🔄 進行中 | - | - | - | sub-agent |
| net | 🔄 進行中 | - | - | - | sub-agent |
| app | 🔄 進行中 | - | - | - | sub-agent |
| location | 🔄 進行中 | - | - | - | sub-agent |
| jobscheduler | 🔄 進行中 | - | - | - | sub-agent |

### 第二階段（驗證）

| 領域 | 狀態 | 驗證通過 | 待驗證 | 問題 |
|------|------|----------|--------|------|
| display | 🔄 進行中 | 11/24 | 6 | 7 |
| 其他 | ⏳ 等待 | - | - | - |

---

## 設備狀態

| 設備 | 序號 | 狀態 |
|------|------|------|
| Pixel 7 (左) | 27161FDH20031X | 🔴 fastboot 卡住 |
| Pixel 7 (右) | 2B231FDH200B4Z | 🔴 fastboot 卡住 |

---

## 參考資源

- AOSP Sandbox: `~/develop_claw/aosp-sandbox-2/`
- CTS 測試: `~/develop_claw/aosp-sandbox-2/cts/tests/`
- 乾淨 Image: `~/aosp-images/clean-panther-14/`
- Display 題庫參考: `~/develop_claw/cts-exam-bank/domains/display/`
