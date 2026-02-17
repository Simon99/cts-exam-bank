# Q003 Answer: getDefaultSensor with wakeUp Flag Ignored

## 問題根因
在 `SensorManager.java` 的 `getDefaultSensor(int, boolean)` 方法中，
過濾邏輯只檢查了 type，完全忽略了 wakeUp 參數。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼（忽略 wakeUp 參數）
public Sensor getDefaultSensor(int type, boolean wakeUp) {
    List<Sensor> sensorList = getSensorList(type);
    for (Sensor sensor : sensorList) {
        if (sensor.getType() == type) {  // 只檢查 type
            return sensor;
        }
    }
    return null;
}

// 正確的代碼
public Sensor getDefaultSensor(int type, boolean wakeUp) {
    List<Sensor> sensorList = getSensorList(type);
    for (Sensor sensor : sensorList) {
        if (sensor.isWakeUpSensor() == wakeUp) {
            return sensor;
        }
    }
    return null;
}
```

## 相關知識
- Wake-up 感測器可在 AP 休眠時喚醒系統
- 同類型感測器可能有 wake-up 和 non-wake-up 兩個版本
- CDD 要求某些感測器必須有 wake-up 版本

## 難度說明
**Medium** - 需要理解 wake-up 感測器的概念並追蹤參數使用。
