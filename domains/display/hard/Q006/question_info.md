# display_hard_Q006

## 基本資訊
- **ID**: DIS-H006
- **標題**: Virtual Display System Decoration Flag Bypass
- **CTS 測試**: `android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-21)

## 問題簡述
Inverted condition causes SHOULD_SHOW_SYSTEM_DECORATIONS flag to be stripped from trusted displays instead of untrusted ones

## 涉及概念
virtual-display, security, flag-validation, system-decoration, condition-inversion

## 修正複雜度
Change != 0 back to == 0
