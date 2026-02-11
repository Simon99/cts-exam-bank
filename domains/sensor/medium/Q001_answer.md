# Q001 Answer: Sensor Batching Not Honoring maxReportLatencyUs

## 問題根因
在 `SensorManager.java` 的 4 參數版 `registerListener()` 中，
`maxReportLatencyUs` 參數被轉換時單位弄錯了。
應該直接傳遞微秒值，但 bug 將其除以 1000 變成毫秒，
導致 5 秒變成 5 毫秒，批次延遲幾乎無效。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public boolean registerListener(SensorEventListener listener, Sensor sensor,
        int samplingPeriodUs, int maxReportLatencyUs) {
    int latency = maxReportLatencyUs / 1000;  // BUG: 不需要轉換
    return registerListenerImpl(listener, sensor, 
            getDelay(samplingPeriodUs), null, latency, 0);
}

// 正確的代碼
public boolean registerListener(SensorEventListener listener, Sensor sensor,
        int samplingPeriodUs, int maxReportLatencyUs) {
    return registerListenerImpl(listener, sensor, 
            getDelay(samplingPeriodUs), null, maxReportLatencyUs, 0);
}
```

## 相關知識
- Sensor batching 在 Android 4.4+ 引入
- maxReportLatencyUs 允許系統延遲事件傳遞以省電
- 參數單位是微秒 (μs)，1 秒 = 1,000,000 μs

## 難度說明
**Medium** - 需要理解 batching 機制並追蹤參數傳遞過程。
