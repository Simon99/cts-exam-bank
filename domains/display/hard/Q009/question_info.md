# display_hard_Q009

## 基本資訊
- **ID**: DIS-H009
- **標題**: Display Mode Request Setting Getter Returns Inverted Value
- **CTS 測試**: `android.display.cts.DisplayTest#testModeSwitchOnPrimaryDisplay`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-21)

## 問題簡述
Getter returns inverted value, causing set/get mismatch

## 涉及概念
getter-setter-mismatch, return-value-inversion, mode-switch, display-config, assertion-failure

## 修正複雜度
Remove the ! operator
