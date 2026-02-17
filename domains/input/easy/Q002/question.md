# Q002: MotionEvent 座標取得錯誤

## CTS Test
`android.view.cts.TouchScreenTest#testGetXY`

## Failure Log
```
junit.framework.AssertionFailedError: getX() returned wrong value
Expected: 150.0 (within tolerance 1.0)
Actual: 0.0

at android.view.cts.TouchScreenTest.testGetXY(TouchScreenTest.java:89)
```

## 現象描述
CTS 測試報告 `MotionEvent.getX()` 回傳 0.0，而預期值為觸控位置的 X 座標。
使用者在螢幕上觸碰時，應該能取得正確的觸控座標。

## 提示
- 此測試檢查觸控座標是否正確回傳
- `getX()` 應該回傳第一個觸控點的 X 座標
- 問題可能在座標值的取得邏輯

## 選項

A) `getX()` 中將浮點運算結果強制轉型為 int 後再轉回 float

B) `getX()` 中使用了錯誤的 pointer index (傳入 1 而非 0)

C) `getX()` 回傳時使用了 `mX` 而非正確的 native 方法呼叫

D) `getX()` 中的 native 方法呼叫忘記傳入 pointer index 參數
