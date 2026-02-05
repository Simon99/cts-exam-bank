# Display-E-Q003 解答

## Root Cause
`DisplayManagerService.java` 第 593 行，`mWideColorSpace` 初始化時使用了錯誤的陣列索引。

原本：`mWideColorSpace = colorSpaces[1];`（Wide color space）
被改成：`mWideColorSpace = colorSpaces[0];`（sRGB / default）

`SurfaceControl.getCompositionColorSpaces()` 回傳的陣列中，`[0]` 是 sRGB，`[1]` 才是 wide gamut color space。取 `[0]` 導致 `getPreferredWideGamutColorSpace()` 回傳 sRGB，CTS 驗證時發現回傳的不是 wide gamut → assertFalse 失敗。

## 涉及檔案
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`（第 593 行）

## Bug Pattern
Pattern A（縱向單點）

## 追蹤路徑
1. CTS log → `testGetPreferredWideGamutColorSpace` 的 `assertFalse` 失敗
2. 查 CTS 源碼 → 測試呼叫 `display.getPreferredWideGamutColorSpace()`
3. 追蹤 API → `DisplayManagerGlobal.getPreferredWideGamutColorSpace()` → Binder 到 `DisplayManagerService`
4. 找到 `getPreferredWideGamutColorSpaceIdInternal()` → 回傳 `mWideColorSpace.getId()`
5. 看 `mWideColorSpace` 在哪裡賦值 → 建構子中 `colorSpaces[0]`，應該是 `[1]`

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 DisplayManagerService.java |
| 正確定位 bug 位置 | 20% | 第 593 行 colorSpaces index |
| 理解 root cause | 20% | 能解釋 [0] 是 sRGB、[1] 是 wide gamut |
| 修復方案正確 | 10% | 改回 colorSpaces[1] |
| 無 side effect | 10% | 不影響其他色域相關功能 |
