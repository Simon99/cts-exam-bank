# Q007 Answer: requestTriggerSensorImpl Doesn't Prevent Double Registration

## 問題根因
在 `SystemSensorManager.java` 的 `requestTriggerSensorImpl()` 方法中，
沒有檢查 listener 是否已經註冊過。每次呼叫都會在 HAL 層新增一個請求，
導致同一事件觸發多個回調。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（不檢查重複）
@Override
protected boolean requestTriggerSensorImpl(TriggerEventListener listener,
        Sensor sensor) {
    TriggerEventQueue queue = new TriggerEventQueue(listener, ...);
    // BUG: 直接加入，不檢查是否已存在
    synchronized (mTriggerListeners) {
        mTriggerListeners.add(queue);
    }
    return nativeRequestTriggerSensor(sensor.getHandle());
}

// 正確的代碼
@Override
protected boolean requestTriggerSensorImpl(TriggerEventListener listener,
        Sensor sensor) {
    synchronized (mTriggerListeners) {
        // 先檢查是否已註冊
        for (TriggerEventQueue existing : mTriggerListeners) {
            if (existing.mListener == listener && existing.mSensor == sensor) {
                // 已註冊，返回 true 但不重複加入
                return true;
            }
        }
        TriggerEventQueue queue = new TriggerEventQueue(listener, ...);
        mTriggerListeners.add(queue);
    }
    return nativeRequestTriggerSensor(sensor.getHandle());
}
```

## 相關知識
- Trigger sensor 是一次性感測器（ONE_SHOT reporting mode）
- 相同 listener+sensor 的重複請求應該是冪等的
- HAL 層可能不會去重，需要 framework 處理

## 難度說明
**Hard** - 需要理解 trigger sensor 的語義和去重邏輯。
