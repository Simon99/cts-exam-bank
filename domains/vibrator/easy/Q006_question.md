# Q006: Default Vibration Intensity Wrong Value

## CTS Test
`android.os.cts.VibratorTest#testGetDefaultVibrationIntensity`

## Failure Log
```
junit.framework.AssertionFailedError: Default vibration intensity out of range
getDefaultVibrationIntensity(USAGE_RINGTONE) returned -1
expected value in range [0, 3] but was:<-1>

at android.os.cts.VibratorTest.testGetDefaultVibrationIntensity(VibratorTest.java:221)
```

## 現象描述
`getDefaultVibrationIntensity()` 回傳 -1，但有效的強度值應該在 0-3 範圍內。
- 0 = VIBRATION_INTENSITY_OFF
- 1 = VIBRATION_INTENSITY_LOW
- 2 = VIBRATION_INTENSITY_MEDIUM
- 3 = VIBRATION_INTENSITY_HIGH

## 提示
- 檢查 `getDefaultVibrationIntensity()` 的實作
- 注意預設值或 fallback 邏輯
- -1 通常表示「未設定」或「錯誤」
