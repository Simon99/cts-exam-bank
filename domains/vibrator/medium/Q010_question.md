# Q010: CombinedVibration Parallel Missing Effect

## CTS Test
`android.os.cts.CombinedVibrationTest#testCreateParallel`

## Failure Log
```
junit.framework.AssertionFailedError: CombinedVibration.createParallel lost effect
Created with VibrationEffect duration 500ms
ParallelCombination.getVibrators() returned empty map

at android.os.cts.CombinedVibrationTest.testCreateParallel(CombinedVibrationTest.java:87)
```

## 現象描述
呼叫 `CombinedVibration.createParallel(effect)` 建立平行振動，
但產生的 CombinedVibration 內部沒有包含任何振動效果。

## 提示
- 檢查 createParallel() 的效果儲存邏輯
- 注意 Builder pattern 的使用
- 可能忘記加入效果或建立物件
