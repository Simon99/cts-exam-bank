# Q001: Vibrator Availability Check Failed

## CTS Test
`android.os.cts.VibratorTest#testHasVibrator`

## Failure Log
```
junit.framework.AssertionFailedError: hasVibrator() returned false but device has hardware vibrator
expected:<true> but was:<false>

at android.os.cts.VibratorTest.testHasVibrator(VibratorTest.java:68)
```

## 現象描述
CTS 測試報告 `hasVibrator()` 回傳 false，但裝置明確具有振動器硬體。
透過 adb shell 檢查 `/sys/class/leds/vibrator/` 可以確認硬體存在，
但 API 回報不存在。

## 提示
- 檢查 `Vibrator.java` 中 `hasVibrator()` 的實作邏輯
- 此方法透過 `VibratorInfo` 取得振動器資訊
- 注意布林值判斷的邏輯是否正確
