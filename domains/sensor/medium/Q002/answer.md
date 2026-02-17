# Q002 Answer: flush() Returns True But Events Never Arrive

## 問題根因
在 `SensorManager.java` 的 `flush()` 方法中，
需要檢查 listener 是否為 `SensorEventListener2` 才能發送 flush 請求。
Bug 是類型檢查的邏輯顛倒，導致對 SensorEventListener2 不發送 flush，
而對普通 SensorEventListener 錯誤地嘗試發送。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorManager.java`

## 修復方式
```java
// 錯誤的代碼
public boolean flush(SensorEventListener listener) {
    if (listener == null) {
        throw new IllegalArgumentException("listener cannot be null");
    }
    // BUG: 邏輯顛倒
    if (!(listener instanceof SensorEventListener2)) {
        return flushImpl(listener);  // 不應該 flush
    }
    return true;  // 應該要 flush
}

// 正確的代碼
public boolean flush(SensorEventListener listener) {
    if (listener == null) {
        throw new IllegalArgumentException("listener cannot be null");
    }
    if (listener instanceof SensorEventListener2) {
        return flushImpl(listener);
    }
    return false;  // 不支援 flush 的 listener
}
```

## 相關知識
- SensorEventListener2 擴展 SensorEventListener，增加 onFlushCompleted()
- flush() 強制立即傳送 FIFO 中的所有批次事件
- 只有 SensorEventListener2 支援 flush callback

## 難度說明
**Medium** - 需要理解 SensorEventListener vs SensorEventListener2 的差異。
