# Q001: Waveform Amplitudes Array Length Mismatch

## CTS Test
`android.os.cts.VibrationEffectTest#testCreateWaveformWithAmplitudes`

## Failure Log
```
junit.framework.AssertionFailedError: createWaveform should reject mismatched arrays
VibrationEffect.createWaveform(
    new long[]{100, 200, 100},    // 3 elements
    new int[]{128, 255},           // 2 elements  
    -1) 
did not throw IllegalArgumentException

Arrays must have equal length

at android.os.cts.VibrationEffectTest.testCreateWaveformWithAmplitudes(VibrationEffectTest.java:256)
```

## 現象描述
呼叫 `createWaveform(timings, amplitudes, repeat)` 時，
timings 有 3 個元素，amplitudes 只有 2 個元素，
應該拋出 IllegalArgumentException，但沒有。

## 提示
- 檢查 createWaveform 的陣列長度驗證
- 注意兩個陣列的關係
- 可能使用了錯誤的比較運算符
