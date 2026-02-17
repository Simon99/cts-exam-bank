# Q001 Answer: Direct Channel Configuration Causes Crash

## 問題根因
在 `SensorDirectChannel.java` 的 `configure()` 方法中，
狀態檢查過於嚴格。當 channel 狀態為 `CONFIGURED`（已有一個感測器運作）時，
配置第二個感測器應該被允許，但 bug 只允許在 `OPEN` 或 `STOPPED` 狀態下配置。

## Bug 位置
`frameworks/base/core/java/android/hardware/SensorDirectChannel.java`

## 修復方式
```java
// 錯誤的代碼（狀態檢查過嚴）
public int configure(Sensor sensor, int rateLevel) {
    if (mState != STATE_OPEN && mState != STATE_STOPPED) {
        throw new IllegalStateException(
            "Direct channel not in valid state for configure");
    }
    int result = mManager.configureDirectChannelImpl(this, sensor, rateLevel);
    if (result > 0) {
        mState = STATE_CONFIGURED;
    }
    return result;
}

// 正確的代碼
public int configure(Sensor sensor, int rateLevel) {
    // STATE_CONFIGURED 也是有效狀態，可以配置更多感測器
    if (mState != STATE_OPEN && mState != STATE_STOPPED 
            && mState != STATE_CONFIGURED) {
        throw new IllegalStateException(
            "Direct channel not in valid state for configure");
    }
    int result = mManager.configureDirectChannelImpl(this, sensor, rateLevel);
    if (result > 0) {
        mState = STATE_CONFIGURED;
    }
    return result;
}
```

## 相關知識
- Direct Channel 狀態機：OPEN → CONFIGURED → STOPPED → CLOSED
- 一個 channel 可配置多個感測器
- configure() 返回 token 用於識別配置

## 難度說明
**Hard** - 需要理解 Direct Channel 的狀態機和多感測器配置的行為。
