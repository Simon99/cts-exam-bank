# Q010 Answer: SensorEvent Timestamp Off by Factor of 1000

## 問題根因
在 `SystemSensorManager.java` 處理 sensor event 時，
timestamp 被錯誤地除以 1000。HAL 傳入的已經是奈秒，
不需要任何轉換，但 bug 將其轉成微秒。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼
void dispatchSensorEvent(int handle, float[] values, int accuracy, 
        long timestamp) {
    // ...
    SensorEvent event = new SensorEvent(sensor);
    event.timestamp = timestamp / 1000;  // BUG: 不應該除
    event.accuracy = accuracy;
    System.arraycopy(values, 0, event.values, 0, values.length);
    listener.onSensorChanged(event);
}

// 正確的代碼
void dispatchSensorEvent(...) {
    // ...
    event.timestamp = timestamp;  // 直接使用 HAL 傳入的奈秒值
    // ...
}
```

## 相關知識
- SensorEvent.timestamp 以奈秒為單位
- 與 System.nanoTime() 使用相同的時間基準
- timestamp 用於同步來自不同感測器的事件

## 難度說明
**Medium** - 需要理解 timestamp 的單位並追蹤數值流向。
