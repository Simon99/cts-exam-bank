# CTS 題庫腳本使用指南

**版本:** v1.0  
**更新:** 2026-02-20

---

## 腳本清單

| 腳本 | 版本 | 位置 | 用途 |
|------|------|------|------|
| `cts-verify-v2.4.sh` | v2.4 | `tools/` | 題目驗證（patch → build → flash → CTS） |
| `check-question-completeness.sh` | v1.1 | `tools/` | 檢查題目完整性 |
| `backup-cts-results.sh` | v1.0 | `tools/` | 備份 CTS 結果到題目目錄 |

---

## 1. cts-verify-v2.4.sh — 題目驗證

**功能:** 完整驗證流程：apply patch → build AOSP → flash → run CTS → 記錄結果

### 使用方式
```bash
cd ~/develop_claw/cts-exam-bank/tools

# 一次驗一題，驗證完回主 session 報告結果
CTS_DEVICE=27161FDH20031X ./cts-verify-v2.4.sh domains/display/easy/Q001

# ⚠️ 不支持批量驗證 — 一次只驗一題
```

### 環境變數
| 變數 | 預設值 | 說明 |
|------|--------|------|
| `CTS_DEVICE` | 自動偵測 | 指定設備序號 |
| `AOSP_ROOT` | `~/develop_claw/aosp-sandbox-2` | AOSP 源碼路徑 |
| `CTS_ROOT` | `~/android-cts` | CTS 測試套件路徑 |

### 輸出位置
- **CTS 結果:** `domains/<領域>/<難度>/<題目>/cts-results/`
- **Log:** `domains/<領域>/<難度>/<題目>/logs/`

### ⚠️ 常見錯誤
```bash
# ❌ 錯誤：設備序號被當成題目路徑
./cts-verify-v2.4.sh Q002 27161FDH20031X

# ✅ 正確：用環境變數指定設備
CTS_DEVICE=27161FDH20031X ./cts-verify-v2.4.sh domains/display/easy/Q002
```

---

## 2. check-question-completeness.sh — 題目完整性檢查

**功能:** 檢查題目是否包含必要檔案、CTS 結果、logs 等

### 使用方式
```bash
cd ~/develop_claw/cts-exam-bank/tools

# 檢查單題
./check-question-completeness.sh domains/display/easy/Q001

# 檢查某領域某難度的所有題目
./check-question-completeness.sh display easy

# 檢查某領域所有難度
./check-question-completeness.sh display

# 檢查所有題目
./check-question-completeness.sh

# 檢查並更新 meta.json
./check-question-completeness.sh --update display easy
```

### 檢查項目
- `question.md` — 題目描述
- `answer.md` — 答案說明
- `meta.json` — 題目元數據
- `bug.patch` — Bug patch 檔案
- `cts-results/` — CTS 測試結果
- `logs/` — 驗證 log

---

## 3. backup-cts-results.sh — 備份 CTS 結果

**功能:** 將 CTS 測試結果完整備份到題目目錄

### 使用方式
```bash
cd ~/develop_claw/cts-exam-bank/tools

# 備份最新結果
./backup-cts-results.sh display easy Q001

# 指定特定結果目錄
./backup-cts-results.sh display easy Q001 2026.02.17_17.18.40.043_3970
```

---

## 常見問題排解

### 1. fastboot/adb 找不到
```bash
# 設定 PATH
export PATH=$PATH:~/Android/Sdk/platform-tools
```

### 2. Flash 卡住或 timeout
- **原因:** USB 連接問題（進程卡在 D 狀態）
- **解法:** 手動重插 USB 線，或長按電源鍵 10 秒強制重啟

### 3. 長時間操作被 kill
```bash
# 用 nohup 執行
nohup ./cts-verify-v2.4.sh domains/display/easy/Q001 > verify.log 2>&1 &
```

---

## 目錄結構
```
~/develop_claw/cts-exam-bank/
├── tools/                    # 腳本目錄
│   ├── cts-verify-v2.4.sh
│   ├── check-question-completeness.sh
│   └── backup-cts-results.sh
├── domains/                  # 題目目錄
│   └── display/
│       ├── easy/
│       ├── medium/
│       └── hard/
└── docs/                     # 文檔
    └── scripts-guide.md      # 本文件
```
