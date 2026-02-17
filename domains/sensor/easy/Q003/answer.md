# Q003 Answer: getDefaultSensor Returns Wrong Type

## 問題根因
在 `SensorManager.java` 的 `getDefaultSensor()` 方法中，
過濾邏輯使用了錯誤的比較運算符。應該是 `==` 比較感測器類型，
但 bug 使用了 `!=`，導致返回第一個「不是」該類型的感測器。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public Sensor getDefaultSensor(int type) {
    List<Sensor> sensorList = getSensorList(Sensor.TYPE_ALL);
    for (Sensor sensor : sensorList) {
        if (sensor.getType() != type) {  // BUG: 應該是 ==
            return sensor;
        }
    }
    return null;
}

// 正確的代碼
public Sensor getDefaultSensor(int type) {
    List<Sensor> sensorList = getSensorList(Sensor.TYPE_ALL);
    for (Sensor sensor : sensorList) {
        if (sensor.getType() == type) {
            return sensor;
        }
    }
    return null;
}
```

## 相關知識
- Sensor.TYPE_ACCELEROMETER = 1
- Sensor.TYPE_GYROSCOPE = 4
- getDefaultSensor 返回第一個匹配類型的感測器

## 難度說明
**Easy** - 錯誤清楚指出類型不匹配，檢查 type 比較邏輯即可發現問題。
