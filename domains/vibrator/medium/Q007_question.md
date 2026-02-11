# Q007: Vibrate With VibrationAttributes Usage Ignored

## CTS Test
`android.os.cts.VibrationAttributesTest#testVibrateWithUsage`

## Failure Log
```
junit.framework.AssertionFailedError: VibrationAttributes usage not applied
vibrate() called with USAGE_ALARM but vibration used USAGE_UNKNOWN
Service log shows: usage=0 (expected usage=17 for ALARM)

at android.os.cts.VibrationAttributesTest.testVibrateWithUsage(VibrationAttributesTest.java:156)
```

## 現象描述
呼叫 `vibrate(VibrationEffect, VibrationAttributes)` 時傳入 USAGE_ALARM 的屬性，
但實際振動使用的 usage 是 USAGE_UNKNOWN (0)。

## 提示
- 檢查 vibrate() 方法如何傳遞 VibrationAttributes
- 注意 attributes 參數是否被正確使用
- 可能使用了預設屬性而非傳入的屬性
