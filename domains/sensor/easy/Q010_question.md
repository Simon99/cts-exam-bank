# Q010: SensorDirectChannel.isOpen() Always Returns True

## CTS Test
`android.hardware.cts.SensorDirectReportTest#testDirectChannelClose`

## Failure Log
```
junit.framework.AssertionFailedError: isOpen() should return false after close()
expected: false but was: true

SensorDirectChannel was closed successfully but isOpen() still returns true

at android.hardware.cts.SensorDirectReportTest.testDirectChannelClose(SensorDirectReportTest.java:187)
```

## 現象描述
呼叫 `SensorDirectChannel.close()` 後，`isOpen()` 應該返回 false，
但實際仍返回 true。

## 提示
- isOpen() 檢查內部狀態變數
- close() 應該更新此狀態
- 問題可能在於 close() 未正確設定狀態
