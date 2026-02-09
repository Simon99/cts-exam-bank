# Q002 - Display 模式 Alternative Refresh Rates 不對稱

## 問題描述

CTS 測試 `CtsDisplayTestCases#testGetSupportedModesOnDefaultDisplay` 失敗。

測試預期 `getAlternativeRefreshRates()` 返回的替代刷新率具有對稱性，但實際結果不對稱。

## 失敗訊息

```
java.lang.AssertionError: Expected {id=1, 1080x2400, 60.0Hz} to be listed as 
alternative refresh rate of {id=2, 1080x2400, 90.0Hz}. All supported modes are [...]
```

## 考察重點

- 理解 Display Mode 的 alternative refresh rates 概念
- 追蹤 alternativeRefreshRates 的計算邏輯
- 找到導致不對稱的條件判斷

## 提示

1. `getAlternativeRefreshRates()` 返回相同分辨率下的其他可用刷新率
2. 這些 alternative 應該是**對稱的**（A 是 B 的 alternative ↔ B 是 A 的 alternative）
3. 搜索關鍵字：`alternativeRefreshRates`、`isAlternative`
4. 檢查 `LocalDisplayAdapter` 中的計算邏輯
