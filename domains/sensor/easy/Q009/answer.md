# Q009 Answer: cancelTriggerSensor Returns False for Valid Request

## 問題根因
在 `SensorManager.java` 的 `cancelTriggerSensor()` 方法中，
返回值的布林邏輯顛倒了。當成功取消時應該返回 true，
但 bug 導致返回 false。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public boolean cancelTriggerSensor(TriggerEventListener listener, Sensor sensor) {
    if (listener == null || sensor == null) {
        return false;
    }
    boolean result = cancelTriggerSensorImpl(listener, sensor, true);
    return !result;  // BUG: 不應該取反
}

// 正確的代碼
public boolean cancelTriggerSensor(TriggerEventListener listener, Sensor sensor) {
    if (listener == null || sensor == null) {
        return false;
    }
    boolean result = cancelTriggerSensorImpl(listener, sensor, true);
    return result;  // 直接返回結果
}
```

## 相關知識
- Trigger sensor（如 Significant Motion）只觸發一次
- cancelTriggerSensor 用於在觸發前取消請求
- 返回 true 表示成功取消，false 表示失敗

## 難度說明
**Easy** - 返回值顛倒是常見錯誤，直接檢查返回邏輯即可。
