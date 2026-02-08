# Review Needed — 題目審核規則

**版本：** 1.0  
**更新時間：** 2026-02-08

---

## 目的

收集不滿足題庫需求的題目，分類保存供後續分析改進。

## 目錄結構

```
review_needed/
├── bootloop/           # 開機異常（無法正常啟動）
├── test_error/         # CTS 測試本身出錯（非預期 fail）
├── unexpected_behavior/ # 非預期行為（bug 效果不如預期）
└── other/              # 其他需要人工審核的情況
```

## 分類標準

### 1. bootloop/
**觸發條件：**
- 刷機後手機無法開機（卡 bootanimation、反覆重啟）
- `adb wait-for-device` 超過 5 分鐘無回應

**記錄內容：**
- 題目 ID（如 `Q001`）
- 修改的源碼位置
- build log（如有）
- 現象描述

### 2. test_error/
**觸發條件：**
- CTS 測試 crash 或 timeout（非正常 FAIL）
- 測試報告顯示 `ERROR` 而非 `FAIL`
- 測試無法執行（setup 失敗等）

**記錄內容：**
- 題目 ID
- 測試名稱
- CTS log 路徑
- 錯誤訊息

### 3. unexpected_behavior/
**觸發條件：**
- Bug 埋點成功，但 CTS 結果不如預期（例如應該 fail 卻 pass）
- Bug 造成的影響超出預期範圍
- 題目難度評估與實際不符

**記錄內容：**
- 題目 ID
- 預期行為 vs 實際行為
- 分析/推測原因

### 4. other/
**觸發條件：**
- 不屬於以上分類
- 需要討論才能決定如何處理

---

## 文件命名格式

```
{日期}_{題目ID}_{簡短描述}.md

# 範例
2026-02-08_Q003_brightness_bootloop.md
2026-02-08_Q001_test_timeout.md
```

## 文件模板

```markdown
# Review Needed: {題目ID}

**日期：** YYYY-MM-DD  
**分類：** bootloop / test_error / unexpected_behavior / other  
**狀態：** 待分析 / 已分析 / 已解決 / 放棄

## 題目資訊
- **題目 ID：** Q00X
- **難度：** easy / medium / hard
- **所屬模組：** CtsDisplayTestCases / ...
- **目標測試：** testXxx

## 問題描述
（描述發生了什麼）

## 修改內容
（埋了什麼 bug、修改了哪個檔案）

## 相關 Log
（CTS log 路徑、logcat 摘要等）

## 分析
（根因分析、為什麼會這樣）

## 後續處理
（如何改進、是否放棄此題等）
```

---

## 工作流程

1. **發現問題** → 判斷分類
2. **建立文件** → 放到對應子目錄
3. **填寫模板** → 記錄必要資訊
4. **標記狀態** → 待分析
5. **後續分析** → 更新文件、決定處理方式

---

*v1.0 | 2026-02-08*
