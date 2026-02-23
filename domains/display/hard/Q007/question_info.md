# display_hard_Q007

## 基本資訊
- **ID**: DIS-H007
- **標題**: Display Event DISPLAY_ADDED Not Delivered to Listeners
- **CTS 測試**: `android.display.cts.DisplayTest#testMode`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-21)

## 問題簡述
shouldSendEvent() checks wrong flag for DISPLAY_ADDED events, causing them to be silently dropped

## 涉及概念
display-event, event-listener, flag-mismatch, event-filtering, callback, timeout

## 修正複雜度
Change flag constant in switch-case
