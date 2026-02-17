# Q002: Composition Primitive Delay Accumulation Error

## CTS Test
`android.os.cts.VibrationEffectTest#testCompositionPrimitiveDelay`

## Failure Log
```
junit.framework.AssertionFailedError: Composition total duration incorrect
Composition: CLICK(delay=100) + TICK(delay=200) + CLICK(delay=150)
Expected total delay: 450ms (100 + 200 + 150)
Actual total delay: 350ms

Duration calculation appears to skip first delay

at android.os.cts.VibrationEffectTest.testCompositionPrimitiveDelay(VibrationEffectTest.java:398)
```

## 現象描述
組合多個帶延遲的原語時，總延遲計算少了 100ms。
三個原語的延遲分別是 100、200、150，
但計算結果是 350 而非 450。

## 提示
- 檢查 Composition 的延遲累加邏輯
- 注意迴圈的起始索引
- 第一個延遲可能被跳過
