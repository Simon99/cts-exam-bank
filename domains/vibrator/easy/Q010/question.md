# Q010: VibrationEffect Duration Calculation Error

## CTS Test
`android.os.cts.VibrationEffectTest#testGetDuration`

## Failure Log
```
junit.framework.AssertionFailedError: VibrationEffect duration mismatch
createOneShot(1000, DEFAULT_AMPLITUDE).getDuration() returned 0
expected:<1000> but was:<0>

at android.os.cts.VibrationEffectTest.testGetDuration(VibrationEffectTest.java:189)
```

## 現象描述
建立一個 1000ms 的 OneShot 振動效果後，呼叫 `getDuration()` 回傳 0。
此方法應該回傳振動效果的總持續時間。

## 提示
- 檢查 `OneShot` 類別的 `getDuration()` 實作
- 注意回傳的變數是否正確
- 可能回傳了錯誤的成員變數
