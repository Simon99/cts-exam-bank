# Q003: Basic Vibration Duration Error

## CTS Test
`android.os.cts.VibratorTest#testVibrateDuration`

## Failure Log
```
junit.framework.AssertionFailedError: Vibration duration mismatch
Requested 500ms but vibration lasted approximately 50ms
expected duration >= 450ms but was:<48ms>

at android.os.cts.VibratorTest.testVibrateDuration(VibratorTest.java:142)
```

## 現象描述
CTS 測試請求 500ms 的振動，但實際振動時間只有約 50ms。
振動確實有觸發，但持續時間遠短於預期。

## 提示
- 檢查 `vibrate(long milliseconds)` 方法的參數處理
- 注意時間單位是否正確（毫秒 vs 其他單位）
- 可能存在數值運算錯誤
