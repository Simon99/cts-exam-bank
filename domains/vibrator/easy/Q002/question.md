# Q002: Amplitude Control Support Check Failed

## CTS Test
`android.os.cts.VibratorTest#testHasAmplitudeControl`

## Failure Log
```
junit.framework.AssertionFailedError: hasAmplitudeControl() returned true 
but device does not support amplitude control
expected:<false> but was:<true>

at android.os.cts.VibratorTest.testHasAmplitudeControl(VibratorTest.java:95)
```

## 現象描述
CTS 測試報告 `hasAmplitudeControl()` 回傳 true，但裝置實際上不支援振幅控制。
當嘗試使用不同振幅振動時，所有振幅效果都是相同強度。

## 提示
- 檢查 `Vibrator.java` 中的能力檢查方法
- 注意 `VibratorInfo.hasAmplitudeControl()` 的呼叫方式
- 布林值可能被硬編碼或條件判斷錯誤
