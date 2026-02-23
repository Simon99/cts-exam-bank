# display_easy_Q010

## 基本資訊
- **ID**: DIS-E010
- **標題**: Overlay Display 信任標記遺失 - FLAG_TRUSTED 被註解掉
- **CTS 測試**: `android.display.cts.DisplayTest#testFlags`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-22)

## 問題簡述
在 OverlayDisplayAdapter 的 getDisplayDeviceInfoLocked() 方法中，設置 FLAG_TRUSTED 的程式碼被註解掉，導致 overlay display 缺少信任標記

## 涉及概念
flag-handling, overlay-display, trust-flag, commented-code, debugging-artifact

## 修正複雜度
single-line
