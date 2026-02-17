# Q005 Answer: flushImpl Deadlock Under Heavy Load

## 問題根因
在 `SystemSensorManager.java` 中，`flushImpl()` 和事件分發的鎖取得順序不一致。
`flushImpl()` 先取 mSensorListeners 再取 queue.mLock，
但事件分發路徑先取 queue.mLock 再取 mSensorListeners。
這導致經典的 ABBA 死鎖。

## Bug 位置
`frameworks/base/core/java/android/hardware/SystemSensorManager.java`

## 修復方式
```java
// 錯誤的代碼（鎖順序不一致）
@Override
protected boolean flushImpl(SensorEventListener listener) {
    SensorEventQueue queue;
    synchronized (mSensorListeners) {  // Lock A first
        queue = mSensorListeners.get(listener);
    }
    if (queue != null) {
        synchronized (queue.mLock) {  // Then lock B
            return queue.flush();
        }
    }
    return false;
}

// 在另一處的事件分發：
void dispatchEvent() {
    synchronized (mLock) {  // Lock B first
        synchronized (mManager.mSensorListeners) {  // Then lock A - DEADLOCK!
            // ...
        }
    }
}

// 正確的代碼（統一鎖順序：永遠先 A 後 B）
@Override
protected boolean flushImpl(SensorEventListener listener) {
    synchronized (mSensorListeners) {  // Always lock A first
        SensorEventQueue queue = mSensorListeners.get(listener);
        if (queue != null) {
            return queue.flush();  // flush 內部不要再取 mSensorListeners
        }
    }
    return false;
}
```

## 相關知識
- ABBA 死鎖：執行緒 1 持有 A 等 B，執行緒 2 持有 B 等 A
- 解決方案：全域統一鎖順序
- Android 感測器框架在高負載下容易觸發此問題

## 難度說明
**Hard** - 需要分析多執行緒的鎖順序和死鎖條件。
