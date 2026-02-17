# Q010: CombinedVibration Parallel Empty Effects Validation

## CTS Test
`android.os.cts.CombinedVibrationTest#testParallelCombinationEmpty`

## Failure Log
```
junit.framework.AssertionFailedError: combine() should reject empty combination
CombinedVibration.startParallel()
    .combine()
did not throw IllegalStateException

ParallelCombination must have at least one vibrator

at android.os.cts.CombinedVibrationTest.testParallelCombinationEmpty(CombinedVibrationTest.java:178)
```

## 現象描述
建立 `ParallelCombination` 後直接呼叫 `combine()` 而不加入任何振動器，
應該拋出 IllegalStateException，但方法成功返回了一個空的組合振動。

## 提示
- 檢查 combine() 的狀態驗證
- 考慮空集合的處理
- 注意 Builder 模式的完整性檢查
