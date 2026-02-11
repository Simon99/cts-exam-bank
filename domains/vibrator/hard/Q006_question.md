# Q006: ParallelCombination Add Vibrator ID Validation

## CTS Test
`android.os.cts.CombinedVibrationTest#testParallelCombinationVibratorId`

## Failure Log
```
junit.framework.AssertionFailedError: addVibrator should reject invalid vibrator ID
ParallelCombination.addVibrator(-5, effect) did not throw IllegalArgumentException
Negative vibrator IDs are invalid

VibratorManager.getVibratorIds() returns [0, 1, 2]
ID -5 does not exist

at android.os.cts.CombinedVibrationTest.testParallelCombinationVibratorId(CombinedVibrationTest.java:178)
```

## 現象描述
呼叫 `ParallelCombination.addVibrator(-5, effect)` 時應該拋出異常，
因為 -5 不是有效的振動器 ID，但沒有拋出。

## 提示
- 檢查 addVibrator() 的 ID 驗證邏輯
- 注意負數 ID 的處理
- 可能使用了錯誤的驗證條件或完全沒有驗證
