# Q002 答案 [Hard]：GNSS First Fix Time Not Reported

## Bug 位置（2 處）

### Bug 1: GnssLocationProvider.java
在 `onReportLocation()` 中，首次定位的處理邏輯被移除：
- 沒有設定 `mHasFirstFix = true`
- 沒有計算 TTFF
- 沒有通知 `GnssStatusProvider`

### Bug 2: GnssStatusProvider.java
即使 `reportFirstFix()` 被呼叫，也沒有將事件傳遞給 listeners。

## 完整呼叫鏈

```
GNSS HAL (native)
    → GnssNative.reportLocation() (JNI callback)
        → GnssLocationProvider.onReportLocation() ← BUG 1
            → 應該檢測 first fix 並計算 TTFF
            → 應該呼叫 GnssStatusProvider.reportFirstFix()
                → GnssStatusProvider.reportFirstFix() ← BUG 2
                    → 應該 deliverToListeners()
                        → IGnssStatusListener.onFirstFix()
                            → GnssStatus.Callback.onFirstFix()
```

## 修復方案

### 修復 Bug 1 (GnssLocationProvider.java)
```java
@Override
public void onReportLocation(boolean hasLatLong, Location location) {
    if (hasLatLong && !mHasFirstFix) {
        mHasFirstFix = true;
        int ttff = (int) (SystemClock.elapsedRealtime() - mFixStartTime);
        mGnssMetrics.logFirstFix(ttff);
        mGnssStatusProvider.reportFirstFix(ttff);  // 通知 StatusProvider
    }
    // ... rest of location handling
}
```

### 修復 Bug 2 (GnssStatusProvider.java)
```java
public void reportFirstFix(int ttffMs) {
    deliverToListeners(listener -> {
        listener.onFirstFix(ttffMs);
    });
}
```

## 教學重點

1. **HAL 到 App 的完整路徑**：JNI → Provider → Listener → Callback
2. **First Fix 定義**：GNSS 啟動後第一次獲得有效定位
3. **TTFF 計算**：`elapsedRealtime() - mFixStartTime`
4. **跨模組通訊**：GnssLocationProvider 需要通知 GnssStatusProvider
