# display_easy_Q009

## 基本資訊
- **ID**: DIS-E009
- **標題**: HdrCapabilities minLuminance 返回錯誤值
- **CTS 測試**: `android.display.cts.DisplayTest#testDefaultDisplayHdrCapability`
- **CTS 模組**: CtsDisplayTestCases

## 驗證狀態
- Phase A: ✅ Done
- Phase B: ✅ Done
- Phase C: ✅ Verified (2026-02-22)

## 問題簡述
getDesiredMinLuminance() 錯誤地返回 mMaxLuminance + 100，導致 min > max 違反約束

## 涉及概念
hdr, luminance, display-capability, return-value

## 修正複雜度
single-line
