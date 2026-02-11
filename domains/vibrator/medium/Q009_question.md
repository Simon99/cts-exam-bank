# Q009: VibrationEffect Scale Factor Clamp Error

## CTS Test
`android.os.cts.VibrationEffectTest#testScale`

## Failure Log
```
junit.framework.AssertionFailedError: Scaled amplitude exceeds maximum
Original amplitude: 200, scale: 0.3
Expected scaled amplitude: 60 (200 * 0.3)
Actual scaled amplitude: 0

at android.os.cts.VibrationEffectTest.testScale(VibrationEffectTest.java:378)
```

## 現象描述
呼叫 `VibrationEffect.scale(0.3)` 縮放振幅，
原始振幅 200 預期縮放為 60，但實際結果為 0。

## 提示
- 檢查 scale() 方法的計算邏輯
- 注意整數與浮點數的運算順序
- 可能存在整數除法截斷問題
