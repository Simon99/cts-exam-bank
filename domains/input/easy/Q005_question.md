# Q005: MotionEvent 軸值取得失敗

## CTS Test
`android.view.cts.InputEventTest#testGetAxisValue`

## Failure Log
```
junit.framework.AssertionFailedError: getAxisValue(AXIS_PRESSURE) returned wrong value
Expected: 0.75 (applied pressure)
Actual: 0.0

at android.view.cts.InputEventTest.testGetAxisValue(InputEventTest.java:203)
```

## 現象描述
CTS 測試報告 `MotionEvent.getAxisValue(AXIS_PRESSURE)` 回傳 0.0。
當使用者施加壓力觸控時，壓力值應該被正確回傳。

## 提示
- 此測試檢查軸值 (axis value) 的取得
- MotionEvent 支援多種軸，如 X, Y, PRESSURE, SIZE 等
- 問題可能在於軸值的查詢邏輯

## 選項

A) `getAxisValue()` 中將 axis 參數與 pointer index 參數順序搞反

B) `getAxisValue()` 中沒有呼叫 native 方法，直接回傳 0.0f

C) `getAxisValue()` 中使用了錯誤的常數 `AXIS_X` 取代傳入的 axis 參數

D) `getAxisValue()` 中的條件判斷 `if (axis >= 0)` 寫成 `if (axis > 0)`
