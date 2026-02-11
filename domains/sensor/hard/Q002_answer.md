# Q002 Answer: registerListenerImpl Race Condition Causes Duplicate Events

## 問題根因
在 `SystemSensorManager.java` 的 `registerListenerImpl()` 方法中，
檢查 listener 是否已註冊和實際註冊之間存在競態條件。
使用了 check-then-act 模式而非原子操作，導致可能重複註冊。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（非原子的 check-then-act）
@Override
protected boolean registerListenerImpl(SensorEventListener listener, 
        Sensor sensor, int delayUs, Handler handler, 
        int maxReportLatencyUs, int reservedFlags) {
    synchronized (mSensorListeners) {
        SensorEventQueue queue = mSensorListeners.get(listener);
        if (queue != null) {
            // 更新現有註冊 - 這裡沒問題
            return queue.addSensor(sensor, delayUs, maxReportLatencyUs);
        }
    }
    // BUG: 在 synchronized 區塊外創建新 queue
    SensorEventQueue newQueue = new SensorEventQueue(listener, ...);
    synchronized (mSensorListeners) {
        mSensorListeners.put(listener, newQueue);  // 可能覆蓋另一個執行緒的註冊
    }
    return true;
}

// 正確的代碼
@Override
protected boolean registerListenerImpl(...) {
    synchronized (mSensorListeners) {
        SensorEventQueue queue = mSensorListeners.get(listener);
        if (queue == null) {
            queue = new SensorEventQueue(listener, ...);
            mSensorListeners.put(listener, queue);
        }
        return queue.addSensor(sensor, delayUs, maxReportLatencyUs);
    }
}
```

## 相關知識
- 競態條件：check-then-act 模式在多執行緒下不安全
- Android 允許從不同執行緒呼叫 registerListener
- 重複註冊會導致 HAL 多次報告給同一 listener

## 難度說明
**Hard** - 需要理解多執行緒同步和競態條件。
