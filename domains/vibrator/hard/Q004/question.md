# Q004: VibrationEffect Validate Waveform Timing Error

## CTS Test
`android.os.cts.VibrationEffectTest#testValidateWaveformTimings`

## Failure Log
```
junit.framework.AssertionFailedError: Waveform with negative timing should be invalid
VibrationEffect.createWaveform(new long[]{100, -50, 200}, -1).validate() passed
Negative timing values are invalid

at android.os.cts.VibrationEffectTest.testValidateWaveformTimings(VibrationEffectTest.java:445)
```

## 現象描述
建立包含負數時間值的 Waveform（{100, -50, 200}），
validate() 應該回傳失敗或拋出異常，但驗證通過了。

## 提示
- 檢查 Waveform.validate() 的時間驗證邏輯
- 注意負數的檢查條件
- 可能檢查的是錯誤的變數或使用錯誤的運算符
