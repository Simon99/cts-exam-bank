# Q006 答案 [Hard]：Geofence Exit Event Lost During Power Save

## Bug 位置（2 處）

### Bug 1: onLocationPowerSaveModeChanged() 方法
退出省電模式時，沒有重新評估所有 geofence：
```java
// 遺漏：reevaluateAllGeofences(lastLocation);
```

### Bug 2: onLocationChanged() 方法
省電模式期間收到的位置沒有被儲存，導致位置資訊完全丟失：
```java
// 遺漏：mPendingLocation = location;
```

## 完整呼叫鏈

```
(設備進入省電模式)
DeviceIdleController
    → LocationPowerSaveModeHelper.onIdleModeChanged()
        → GeofenceManager.onLocationPowerSaveModeChanged()

(省電模式期間位置更新)
LocationProviderManager.onLocationChanged()
    → GeofenceManager.onLocationChanged() ← BUG 2
        → 應該儲存 mPendingLocation，但沒有
        → return (不處理)

(退出省電模式)
LocationPowerSaveModeHelper.onIdleModeChanged()
    → GeofenceManager.onLocationPowerSaveModeChanged() ← BUG 1
        → 應該 reevaluateAllGeofences()，但沒有
```

## 修復方案

### 修復 Bug 1
```java
@Override
public void onLocationPowerSaveModeChanged(int mode) {
    synchronized (mMultiplexerLock) {
        int oldMode = mPowerSaveMode;
        mPowerSaveMode = mode;
        
        if (oldMode == LOCATION_MODE_ALL_DISABLED_WHEN_SCREEN_OFF 
                && mode == LOCATION_MODE_NO_CHANGE) {
            // Exiting power save - use pending or last known location
            Location loc = mPendingLocation != null ? mPendingLocation : getLastLocation();
            if (loc != null) {
                reevaluateAllGeofences(loc);
            }
            mPendingLocation = null;
        }
    }
}
```

### 修復 Bug 2
```java
if (mPowerSaveMode == LOCATION_MODE_ALL_DISABLED_WHEN_SCREEN_OFF) {
    mPendingLocation = location;  // Store for later evaluation
    return;
}
```

## 教學重點

1. **省電模式處理**：Doze 模式會暫停位置更新，但需要保存狀態
2. **狀態恢復**：退出限制模式時需要重新評估之前錯過的事件
3. **Geofence 狀態機**：INSIDE ↔ OUTSIDE 轉換需要位置驅動
