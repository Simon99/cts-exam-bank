# Q005: CombinedVibration Synced Effects Order Error

## CTS Test
`android.os.cts.CombinedVibrationTest#testCreateSynced`

## Failure Log
```
junit.framework.AssertionFailedError: Synced vibration execution order incorrect
Created synced vibration with effects for vibrators [1, 2, 3]
Execution order was [3, 2, 1] instead of [1, 2, 3]

Vibrator 1 should start first but started last
Duration: All 500ms but timing offset detected

at android.os.cts.CombinedVibrationTest.testCreateSynced(CombinedVibrationTest.java:134)
```

## 現象描述
使用 `CombinedVibration.createSynced()` 建立同步振動，
預期振動器 1, 2, 3 同時啟動，但實際執行順序相反。
這導致同步效果失敗。

## 提示
- 檢查 createSynced() 的效果排序邏輯
- 注意集合遍歷順序
- 可能使用了逆序的迭代方式
