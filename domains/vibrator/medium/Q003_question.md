# Q003: Waveform Repeat Index Validation Failed

## CTS Test
`android.os.cts.VibrationEffectTest#testCreateWaveformRepeat`

## Failure Log
```
junit.framework.AssertionFailedError: createWaveform should reject invalid repeat index
VibrationEffect.createWaveform(new long[]{100,200,100}, 5) did not throw
Repeat index 5 exceeds array length 3

at android.os.cts.VibrationEffectTest.testCreateWaveformRepeat(VibrationEffectTest.java:224)
```

## 現象描述
呼叫 `createWaveform(timings, repeatIndex)` 時，當 repeatIndex 超過陣列長度，
應該拋出 IllegalArgumentException，但目前未拋出例外。
陣列長度為 3，repeatIndex 為 5，應該被拒絕。

## 提示
- 檢查 createWaveform() 的 repeatIndex 驗證
- 注意是否有遺漏的上界檢查
- repeatIndex 有效範圍是 -1 到 timings.length-1
