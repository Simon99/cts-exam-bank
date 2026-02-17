# Q010 Answer: Sensor Accuracy Callback Invoked with Wrong Sensor

## 問題根因
在 `SystemSensorManager.java` 的 accuracy change dispatch 邏輯中，
使用了錯誤的索引來查找 Sensor 物件。當有多個感測器時，
總是返回列表中的第一個感測器而非對應 handle 的感測器。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（使用錯誤的索引）
void dispatchAccuracyChanged(int handle, int accuracy) {
    SensorEvent event = mSensorEvents.get(handle);
    // BUG: 使用 0 而非 handle 來取得 Sensor
    Sensor sensor = mSensors.get(0);  // 永遠取第一個
    mListener.onAccuracyChanged(sensor, accuracy);
}

// 或者是 handle 映射錯誤
void dispatchAccuracyChanged(int handle, int accuracy) {
    // BUG: 直接用 handle 當 index，但 handle 不是 0-based index
    Sensor sensor = mSensors.get(handle);  
    mListener.onAccuracyChanged(sensor, accuracy);
}

// 正確的代碼
void dispatchAccuracyChanged(int handle, int accuracy) {
    Sensor sensor = mManager.getSensorByHandle(handle);
    if (sensor != null) {
        mListener.onAccuracyChanged(sensor, accuracy);
    }
}
```

## 相關知識
- Sensor handle 是系統指派的唯一識別碼
- handle 不是 0-based index，需要映射查找
- 精確度變化通知需要帶正確的 Sensor 物件

## 難度說明
**Hard** - 需要理解 handle 與 Sensor 物件的映射機制。
