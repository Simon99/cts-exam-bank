# Q010: VelocityTracker 速度取得錯誤

## CTS Test
`android.view.cts.VelocityTrackerTest#testVelocity`

## Failure Log
```
junit.framework.AssertionFailedError: getXVelocity() returned wrong value
Expected: ~1500.0 pixels/second (within tolerance 100.0)
Actual: 0.0

at android.view.cts.VelocityTrackerTest.testVelocity(VelocityTrackerTest.java:98)
```

## 現象描述
CTS 測試報告 `VelocityTracker.getXVelocity()` 回傳 0.0。
手勢滑動後，X 方向速度應該有明確數值。

## 提示
- 此測試檢查速度計算結果
- `getXVelocity()` 應該回傳計算後的 X 方向速度
- 需要先呼叫 `computeCurrentVelocity()` 才能取得速度

## 選項

A) `getXVelocity()` 中使用了錯誤的單位轉換係數

B) `getXVelocity()` 中回傳了 Y 方向速度而非 X 方向

C) `getXVelocity()` 中直接回傳 0.0f

D) `getXVelocity()` 中的 native 方法呼叫少了 pointer id 參數
