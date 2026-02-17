# Q004: getHighestDirectReportRateLevel Returns Unsupported Rate

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testHighestDirectReportRateLevel`

## Failure Log
```
junit.framework.AssertionFailedError: configure() with highest reported rate
level failed
getHighestDirectReportRateLevel returned: RATE_VERY_FAST (3)
but configure(sensor, RATE_VERY_FAST) returns: -22 (EINVAL)

Sensor actually supports up to RATE_FAST (2) only

Suggests getHighestDirectReportRateLevel reports wrong value

at android.hardware.cts.SensorDirectReportTest.testHighestDirectReportRateLevel(SensorDirectReportTest.java:189)
```

## 現象描述
`Sensor.getHighestDirectReportRateLevel()` 返回 `RATE_VERY_FAST`，
但用這個 rate level 呼叫 `configure()` 卻失敗。
感測器實際只支援到 `RATE_FAST`。

## 提示
- Rate level 資訊編碼在 sensor flags 中
- 需要正確解析 flags 中的 rate level 位元
- 問題可能在於位移或遮罩計算
- 考慮 highest rate 的取得邏輯
