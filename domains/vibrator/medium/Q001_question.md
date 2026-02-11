# Q001: Frequency Control Check Returns Wrong Result

## CTS Test
`android.os.cts.VibratorTest#testHasFrequencyControl`

## Failure Log
```
junit.framework.AssertionFailedError: hasFrequencyControl() inconsistent with hardware caps
Device supports frequency range 100-300Hz but hasFrequencyControl() returned false
VibratorInfo.getFrequencyProfile() shows valid FrequencyProfile
expected:<true> but was:<false>

at android.os.cts.VibratorTest.testHasFrequencyControl(VibratorTest.java:128)
```

## 現象描述
裝置硬體支援頻率控制（100-300Hz 範圍），VibratorInfo 也正確回報頻率配置，
但 `hasFrequencyControl()` 卻回傳 false。

## 提示
- 檢查 `hasFrequencyControl()` 如何判斷頻率控制支援
- 注意 FrequencyProfile 的有效性判斷方法
- 可能錯誤地檢查了錯誤的能力
