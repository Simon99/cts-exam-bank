# CTS Exam Bank

Android CTS 面試題庫專案

## 快速連結

| 文件 | 說明 |
|------|------|
| [DOMAIN_STATUS.md](DOMAIN_STATUS.md) | 各領域狀態總覽 |
| [PROGRESS.md](PROGRESS.md) | 專案進度追蹤 |
| [dry-run-failures.md](dry-run-failures.md) | Dry Run 失敗清單 |
| [FIX_QUEUE.md](FIX_QUEUE.md) | 待修復任務 |

## 流程文件

| 文件 | 說明 |
|------|------|
| [PROJECT_DESCRIPTION.md](PROJECT_DESCRIPTION.md) | 專案描述 |
| [QUESTION_GENERATION_FLOW.md](QUESTION_GENERATION_FLOW.md) | 題目產生流程 |
| [REVIEW_CRITERIA.md](REVIEW_CRITERIA.md) | 審查標準 |
| [PHASE_WORKFLOW.md](PHASE_WORKFLOW.md) | 階段工作流程 |

## 目錄結構

```
cts-exam-bank/
├── domains/           # 題目（按領域/難度分類）
│   ├── AlarmManager/
│   ├── app/
│   ├── camera/
│   └── ...
├── injection-points/  # Phase A 注入點列表
└── lessons_learned/   # 經驗紀錄
```

## 統計

- **總題數**: 503
- **領域數**: 15
- **已驗證**: 473 題（成功率 97.9%，463/473）
- **待驗證**: 30 題（display 新增）

---

*最後更新: 2026-02-11 12:40 GMT+8*
