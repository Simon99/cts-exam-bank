# Q002: HDR Type Filtering Logic Error

## 題目背景

你收到了一個 CTS 測試失敗的 bug report：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes

java.lang.AssertionError: 
Expected: [2, 4]
Actual:   []
```

使用者反映：當他們禁用特定的 HDR 格式（如 Dolby Vision 和 HLG）時，`getHdrCapabilities()` 應該只過濾掉這些格式，但實際上卻返回了一個空數組，就像所有 HDR 格式都被禁用了一樣。

## 錯誤描述

`Display.getHdrCapabilities()` 方法在過濾用戶禁用的 HDR 類型時出現邏輯錯誤。當使用者設定禁用某些 HDR 格式（例如 `HDR_TYPE_DOLBY_VISION` 和 `HDR_TYPE_HLG`）時，預期結果應該只過濾掉這些類型，保留其他支援的類型（如 `HDR_TYPE_HDR10` 和 `HDR_TYPE_HDR10_PLUS`）。但目前的實作會將所有 HDR 類型都過濾掉。

## 預期行為

- 支援的 HDR 類型：`[DOLBY_VISION(1), HDR10(2), HLG(3), HDR10_PLUS(4)]`
- 用戶禁用的類型：`[DOLBY_VISION(1), HLG(3)]`
- 預期 `getHdrCapabilities().getSupportedHdrTypes()` 返回：`[HDR10(2), HDR10_PLUS(4)]`

## 實際行為

- 返回空數組 `[]`

## 驗證測試

```bash
atest android.display.cts.DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes
```

## 提示

1. 問題出在客戶端代碼，而非 DisplayManagerService
2. 檢查過濾邏輯中的比較運算符
3. 思考 `contains()` 方法應該如何判斷一個 HDR 類型是否在禁用列表中

## 難度

**Hard** - 需要理解 HDR 能力過濾的完整數據流，從 DisplayManagerService 到客戶端 Display API
