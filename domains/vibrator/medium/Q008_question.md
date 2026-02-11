# Q008: Are Primitives Supported Query Wrong Primitive

## CTS Test
`android.os.cts.VibrationEffectTest#testArePrimitivesSupported`

## Failure Log
```
junit.framework.AssertionFailedError: arePrimitivesSupported returns inconsistent results
Query: [PRIMITIVE_CLICK, PRIMITIVE_TICK]
Expected: [SUPPORTED, SUPPORTED]  (based on single queries)
Actual: [SUPPORTED, UNKNOWN]

Single query PRIMITIVE_TICK returned SUPPORTED
Batch query returned UNKNOWN for same primitive

at android.os.cts.VibrationEffectTest.testArePrimitivesSupported(VibrationEffectTest.java:342)
```

## 現象描述
`arePrimitivesSupported()` 批次查詢的結果與單獨查詢不一致。
單獨查詢 PRIMITIVE_TICK 回傳 SUPPORTED，
但批次查詢時同一個原語回傳 UNKNOWN。

## 提示
- 檢查批次查詢的迴圈索引
- 注意結果陣列的索引對應
- 可能存在查詢順序錯位
