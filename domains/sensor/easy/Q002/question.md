# Q002: UnregisterListener Throws NullPointerException

## CTS Test
`android.hardware.cts.SensorTest#testUnregisterListener`

## Failure Log
```
java.lang.NullPointerException: Attempt to invoke interface method
'void android.hardware.SensorEventListener.onSensorChanged()' on a null object

at android.hardware.SensorManager.unregisterListener(SensorManager.java:702)
at android.hardware.cts.SensorTest.testUnregisterListener(SensorTest.java:203)
```

## 現象描述
呼叫 `unregisterListener(null)` 時應該靜默返回（no-op），
但實際上拋出了 NullPointerException。

## 提示
- unregisterListener 應該容忍 null 參數
- 問題出在 null 檢查的位置
- API 文檔說明傳入 null 是無效操作但不應崩潰
