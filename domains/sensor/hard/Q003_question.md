# Q003: createDirectChannel Leaks Native Resources

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testDirectChannelResourceLeak`

## Failure Log
```
junit.framework.AssertionFailedError: Native resources not properly released
after direct channel creation failure

Test created 100 channels that should have failed
Memory usage increased: 150 MB
Native file descriptors leaked: 100

Expected: failed channels should release resources immediately

at android.hardware.cts.SensorDirectReportTest.testDirectChannelResourceLeak(SensorDirectReportTest.java:312)
```

## 現象描述
當 createDirectChannel 因為參數驗證失敗時（如 memory 太小），
native 資源（如 file descriptor）沒有被正確釋放，
導致重複嘗試會造成資源洩漏。

## 提示
- createDirectChannel 可能在多個地方失敗
- 失敗後應該清理已分配的資源
- 問題可能在於 early return 路徑缺少清理
- 檢查 native 資源的生命週期管理
