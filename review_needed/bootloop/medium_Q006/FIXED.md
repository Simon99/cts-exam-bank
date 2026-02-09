# Q006 已修復

**修復日期:** 2025-02-09

## 原問題
- Bug 導致 bootloop（hasAccess() 邏輯反轉）
- 無法作為面試題使用

## 修復方案
- 重新設計為 VirtualDisplayAdapter FLAG_PRESENTATION 設置錯誤
- 新測試: `android.display.cts.DisplayTest#testFlags`
- Bug 類型: `|=` → `&=` 運算符錯誤
- bootSafe: true

## 文件位置
修復後的文件在:
`~/develop_claw/cts-exam-bank/domains/display/CtsDisplayTestCases/medium/Q006_*`

## 待驗證
需要在設備上實際測試確認 bug 生效且測試失敗。
