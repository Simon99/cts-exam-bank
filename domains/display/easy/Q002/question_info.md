# display_easy_Q002

## 基本資訊
- **ID**: DIS-E002
- **標題**: Overlay Display 高度 Off-by-One 錯誤
- **CTS 測試**: `android.display.cts.DisplayTest#testGetDisplayAttrs`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-22)

## 問題簡述
在 OverlayDisplayAdapter 的 getDisplayDeviceInfoLocked() 方法中，設置高度時錯誤地加了 1，導致 overlay display 回報錯誤的高度

## 涉及概念
off-by-one, height-calculation, overlay-display, display-attributes

## 修正複雜度
single-line
