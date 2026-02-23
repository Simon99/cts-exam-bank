# display_medium_Q008

## 基本資訊
- **ID**: DIS-M008
- **標題**: LogicalDisplay.updateLocked 寬高互換
- **CTS 測試**: `android.display.cts.DisplayTest#testGetMetrics`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-21)

## 問題簡述
LogicalDisplay.updateLocked() 中 mBaseDisplayInfo 的 appWidth 和 appHeight 的來源值互換

## 涉及概念


## 修正複雜度
unknown
