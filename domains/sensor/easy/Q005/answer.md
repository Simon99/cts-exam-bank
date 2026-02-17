# Q005 Answer: isWakeUpSensor Always Returns False

## 問題根因
在 `Sensor.java` 的 `isWakeUpSensor()` 方法中，
使用位元遮罩來檢查 wake-up flag。Bug 是使用了錯誤的遮罩值。

`SENSOR_FLAG_WAKE_UP` 的值是 1（0x1），但代碼中使用了錯誤的位元位置，
導致永遠檢查不到 wake-up flag。

## Bug 位置
`frameworks/base/core/java/android/hardware/Sensor.java`

## 修復方式
```java
// 錯誤的代碼
private static final int SENSOR_FLAG_WAKE_UP = 0x2;  // BUG: 應該是 0x1

public boolean isWakeUpSensor() {
    return (mFlags & SENSOR_FLAG_WAKE_UP) != 0;
}

// 正確的代碼
private static final int SENSOR_FLAG_WAKE_UP = 0x1;

public boolean isWakeUpSensor() {
    return (mFlags & SENSOR_FLAG_WAKE_UP) != 0;
}
```

## 相關知識
- Wake-up 感測器可在 AP 休眠時喚醒系統
- Significant Motion Detector 是 CDD 強制要求的 wake-up 感測器
- mFlags 的位元定義：bit 0 = wake-up, bit 1-2 = reporting mode

## 難度說明
**Easy** - 問題是簡單的常數定義錯誤，只需對比 flag 定義即可發現。
