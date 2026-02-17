# Q008 Answer: unregisterListenerImpl Fails to Stop HAL When Removing Last Sensor

## 問題根因
在 `SystemSensorManager.java` 的 `unregisterListenerImpl()` 方法中，
移除感測器後應該檢查 queue 是否還有其他感測器。如果沒有，應該完全清理 queue
並停止 HAL。Bug 是這個檢查使用了錯誤的方法（`isEmpty()` vs `size() == 0`），
或者在檢查前就已經減少了計數。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼
@Override
protected void unregisterListenerImpl(SensorEventListener listener,
        Sensor sensor) {
    synchronized (mSensorListeners) {
        SensorEventQueue queue = mSensorListeners.get(listener);
        if (queue != null) {
            queue.removeSensor(sensor);
            // BUG: 先移除了 queue，再檢查
            mSensorListeners.remove(listener);
            if (queue.hasSensors()) {  // 這個檢查沒意義了
                mSensorListeners.put(listener, queue);
            }
        }
    }
}

// 正確的代碼
@Override
protected void unregisterListenerImpl(SensorEventListener listener,
        Sensor sensor) {
    synchronized (mSensorListeners) {
        SensorEventQueue queue = mSensorListeners.get(listener);
        if (queue != null) {
            queue.removeSensor(sensor);
            if (!queue.hasSensors()) {
                // 最後一個感測器被移除，清理 queue
                queue.dispose();
                mSensorListeners.remove(listener);
            }
        }
    }
}
```

## 相關知識
- SensorEventQueue 可包含多個感測器的訂閱
- 移除最後一個感測器時需要 dispose() 整個 queue
- dispose() 會通知 HAL 停止事件產生

## 難度說明
**Hard** - 需要理解多感測器訂閱的管理和清理邏輯。
