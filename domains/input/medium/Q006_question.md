# Q006: MotionEvent getHistoricalX() 歷史座標錯誤

## CTS Test
`android.view.cts.MotionEventIsResampledTest#testHistoricalCoordinates`

## Failure Log
```
junit.framework.AssertionFailedError: getHistoricalX() returned wrong value
Expected: 120.5 (second historical X coordinate)
Actual: 100.0 (first historical X coordinate)

at android.view.cts.MotionEventIsResampledTest.testHistoricalCoordinates(MotionEventIsResampledTest.java:112)
```

## 現象描述
CTS 測試報告 `MotionEvent.getHistoricalX(pointerIndex, pos)` 回傳錯誤的歷史座標。
當請求第 2 個歷史位置 (pos=1) 的座標時，卻回傳了第 1 個位置的座標。

## 提示
- `getHistoricalX(int pointerIndex, int pos)` 取得指定歷史位置的 X 座標
- `pos` 參數指定歷史樣本的索引
- 問題可能在於歷史位置參數的處理

## 選項

A) `getHistoricalX()` 中將 `pos` 和 `pointerIndex` 參數順序交換

B) `getHistoricalX()` 中忽略 `pos` 參數，總是傳入 0

C) `getHistoricalX()` 中對 `pos` 取模運算 `pos % 1`

D) `getHistoricalX()` 中將 `pos` 轉型為 float 導致精度問題
