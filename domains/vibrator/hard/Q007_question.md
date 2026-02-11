# Q007: Waveform Repeat Index Boundary Validation

## CTS Test
`android.os.cts.VibrationEffectTest#testCreateWaveformRepeatIndex`

## Failure Log
```
junit.framework.AssertionFailedError: createWaveform should reject invalid repeat index
VibrationEffect.createWaveform(
    new long[]{100, 200, 100},
    new int[]{128, 255, 64},
    3)  // repeat=3, but max valid index is 2
did not throw IllegalArgumentException

Repeat index must be < timings.length or -1

at android.os.cts.VibrationEffectTest.testCreateWaveformRepeatIndex(VibrationEffectTest.java:287)
```

## 現象描述
呼叫 `createWaveform(timings, amplitudes, repeat)` 時，
timings 有 3 個元素（索引 0-2），但 repeat 設為 3，
應該拋出 IllegalArgumentException 表示 repeat 超出範圍，但沒有。

## 提示
- 檢查 repeat 參數的邊界驗證
- repeat=-1 表示不重複，>= 0 表示從該索引開始重複
- 考慮 repeat 的有效範圍應該是什麼
