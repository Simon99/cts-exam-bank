# Q009 Answer: SensorEvent Values Array Index Out of Bounds

## 問題根因
在 `SensorEvent.java` 的建構函數中，values 陣列大小的決定邏輯有錯誤。
對於 Rotation Vector 感測器，應該分配 5 個元素，但 switch-case 中
`TYPE_ROTATION_VECTOR` 的 case 落入了預設的 3 元素邏輯。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorEvent.java`

## 修復方式
```java
// 錯誤的代碼（缺少 break 導致 fall-through）
SensorEvent(Sensor sensor) {
    int size;
    switch (sensor.getType()) {
        case Sensor.TYPE_ACCELEROMETER:
        case Sensor.TYPE_GYROSCOPE:
        case Sensor.TYPE_MAGNETIC_FIELD:
            size = 3;
            break;
        case Sensor.TYPE_ROTATION_VECTOR:
            size = 5;  // BUG: 沒有 break!
        case Sensor.TYPE_ORIENTATION:
            size = 3;
            break;
        default:
            size = 16;
    }
    values = new float[size];
}

// 正確的代碼
SensorEvent(Sensor sensor) {
    int size;
    switch (sensor.getType()) {
        case Sensor.TYPE_ACCELEROMETER:
        case Sensor.TYPE_GYROSCOPE:
        case Sensor.TYPE_MAGNETIC_FIELD:
            size = 3;
            break;
        case Sensor.TYPE_ROTATION_VECTOR:
            size = 5;
            break;  // 加上 break
        case Sensor.TYPE_ORIENTATION:
            size = 3;
            break;
        default:
            size = 16;
    }
    values = new float[size];
}
```

## 相關知識
- Rotation Vector 有 5 個值：x, y, z, cos(θ/2), heading accuracy
- Switch fall-through 是常見的 bug 來源
- 現代 IDE 會警告缺少 break 的情況

## 難度說明
**Hard** - 需要理解不同感測器的 values 結構和 switch fall-through 問題。
