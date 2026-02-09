# Q008 答案 [Hard]：Location Flush Timeout During Provider Transition

## Bug 位置（2 處）

### Bug 1: LocationProviderManager.onProviderEnabledChanged()
Provider 停用時，pending flush requests 被清空而不是保留：
```java
// 錯誤：直接清空
mPendingFlushes.clear();

// 應該：標記為 pending，等 provider 重新啟用時重試
```

### Bug 2: AbstractLocationProvider.onFlush()
Flush 完成時沒有呼叫 callback：
```java
// 遺漏：mListener.onFlushComplete(requestCode);
```

## 完整呼叫鏈

```
LocationManager.requestFlush(provider, listener, 42)
    → LocationManagerService.requestFlush()
        → LocationProviderManager.flush()
            → 添加到 mPendingFlushes
            → AbstractLocationProvider.onFlush() ← BUG 2: 沒有回調
            
(同時)
LocationManager.setTestProviderEnabled(false)
    → LocationProviderManager.onProviderEnabledChanged(false) ← BUG 1
        → mPendingFlushes.clear() (Flush 請求被清除)
```

## 修復方案

### 修復 Bug 1 (LocationProviderManager)
```java
private void onProviderEnabledChanged(boolean enabled) {
    synchronized (mMultiplexerLock) {
        if (!enabled) {
            // Mark pending flushes for later, don't discard
            for (FlushRequest flush : mPendingFlushes) {
                flush.markPending();
            }
        } else {
            // Provider re-enabled, retry pending flushes
            retryPendingFlushes();
        }
    }
}
```

### 修復 Bug 2 (AbstractLocationProvider)
```java
public void onFlush(int requestCode) {
    if (mListener != null) {
        mListener.onFlushComplete(requestCode);
    }
}
```

## 教學重點

1. **狀態轉換處理**：資源（如 pending requests）在狀態變更時需要妥善處理
2. **Callback 保證**：非同步操作必須確保 callback 最終會被呼叫
3. **Flush 機制**：用於強制傳送已緩存的位置，對省電批次模式很重要
4. **不要丟棄請求**：暫時無法處理的請求應該保留或回報錯誤，而不是靜默丟棄
