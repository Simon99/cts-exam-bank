# Q002: CreateOneShot Accepts Invalid Amplitude

## CTS Test
`android.os.cts.VibrationEffectTest#testCreateOneShotAmplitude`

## Failure Log
```
junit.framework.AssertionFailedError: createOneShot should reject amplitude 0
VibrationEffect.createOneShot(500, 0) did not throw IllegalArgumentException
Amplitude 0 is only valid as DEFAULT_AMPLITUDE constant (-1)

at android.os.cts.VibrationEffectTest.testCreateOneShotAmplitude(VibrationEffectTest.java:98)
```

## 現象描述
呼叫 `VibrationEffect.createOneShot(500, 0)` 應該拋出 IllegalArgumentException，
因為 amplitude 值 0 是無效的。有效範圍是 1-255 或 DEFAULT_AMPLITUDE (-1)。
但目前此呼叫成功執行，沒有拋出例外。

## 提示
- 檢查 createOneShot() 的參數驗證邏輯
- 注意 amplitude 的有效範圍邊界
- 0 和 DEFAULT_AMPLITUDE (-1) 是不同的值
