# Q009: VelocityTracker computeCurrentVelocity() 單位錯誤

## CTS Test
`android.view.cts.VelocityTrackerTest#testVelocityUnits`

## Failure Log
```
junit.framework.AssertionFailedError: Velocity units incorrect
Expected: ~1000.0 pixels/second (units=1000)
Actual: ~1.0 pixels/millisecond

at android.view.cts.VelocityTrackerTest.testVelocityUnits(VelocityTrackerTest.java:134)
```

## 現象描述
CTS 測試報告 `VelocityTracker.computeCurrentVelocity(1000)` 計算出的速度值不正確。
傳入 1000 (pixels/second) 但結果看起來是 pixels/millisecond。

## 提示
- `computeCurrentVelocity(int units)` 的 units 參數指定速度單位
- units=1 表示 pixels/millisecond，units=1000 表示 pixels/second
- 問題可能在於 units 參數的處理

## 選項

A) `computeCurrentVelocity()` 中將 units 參數除以 1000

B) `computeCurrentVelocity()` 中忽略 units 參數，使用硬編碼的值 1

C) `computeCurrentVelocity()` 中將 units 轉型為 float 造成精度問題

D) `computeCurrentVelocity()` 中將 units 和速度計算的乘除順序搞反
