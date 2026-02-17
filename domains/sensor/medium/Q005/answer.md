# Q005 Answer: getDynamicSensorList Returns Static Sensors

## 問題根因
在 `SensorManager.java` 的 `getDynamicSensorList()` 方法中，
過濾條件檢查 `isDynamicSensor()` 時使用了錯誤的邏輯。
應該只加入 dynamic 感測器，但 bug 加入了 non-dynamic 感測器。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public List<Sensor> getDynamicSensorList(int type) {
    List<Sensor> result = new ArrayList<>();
    for (Sensor sensor : mFullSensorList) {
        if (!sensor.isDynamicSensor()) {  // BUG: 應該是 isDynamicSensor()
            if (type == Sensor.TYPE_ALL || sensor.getType() == type) {
                result.add(sensor);
            }
        }
    }
    return result;
}

// 正確的代碼
public List<Sensor> getDynamicSensorList(int type) {
    List<Sensor> result = new ArrayList<>();
    for (Sensor sensor : mFullSensorList) {
        if (sensor.isDynamicSensor()) {
            if (type == Sensor.TYPE_ALL || sensor.getType() == type) {
                result.add(sensor);
            }
        }
    }
    return result;
}
```

## 相關知識
- Dynamic sensor 是執行時可熱插拔的感測器
- 常見於 USB HID 感測器或藍牙感測器
- Android 7.0+ 支援 dynamic sensor

## 難度說明
**Medium** - 需要理解 dynamic sensor 概念並檢查過濾邏輯。
