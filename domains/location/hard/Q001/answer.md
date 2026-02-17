# Q001 答案 [Hard]：Location Fusing Accuracy Degradation

## Bug 位置（2 處）

### Bug 1: LocationProviderManager.java
```java
// 錯誤：無論權限等級，都套用 coarse fudging
private Location maybeFudgeLocation(Location location, int permissionLevel) {
    if (permissionLevel == PERMISSION_COARSE) {
        return mLocationFudger.createCoarse(location);
    } else {
        return mLocationFudger.createCoarse(location);  // ← BUG: 應該返回 location
    }
}
```

### Bug 2: LocationFudger.java
```java
// 錯誤：直接設為 1000m，而不是取 max
coarse.setAccuracy(COARSE_ACCURACY_M);  // ← BUG: 應該是 Math.max()
```

## 完整呼叫鏈

```
LocationManager.requestLocationUpdates(FUSED_PROVIDER, ...)
    → LocationManagerService.registerLocationListener()
        → LocationProviderManager.registerListener()
            → (位置更新到達)
            → LocationProviderManager.onLocationChanged()
                → deliverToListeners()
                    → maybeFudgeLocation() ← BUG 1
                        → LocationFudger.createCoarse() ← BUG 2
                            → setAccuracy(1000m)
```

## 修復方案

### 修復 Bug 1 (LocationProviderManager.java)
```java
private Location maybeFudgeLocation(Location location, int permissionLevel) {
    if (permissionLevel == PERMISSION_COARSE) {
        return mLocationFudger.createCoarse(location);
    }
    return location;  // FINE 權限直接返回原始位置
}
```

### 修復 Bug 2 (LocationFudger.java)
```java
public Location createCoarse(Location location) {
    Location coarse = new Location(location);
    coarse.setAccuracy(Math.max(location.getAccuracy(), COARSE_ACCURACY_M));
    addCoarseOffset(coarse);
    return coarse;
}
```

## 教學重點

1. **權限分級**：FINE vs COARSE 權限有不同的位置處理
2. **Multi-bug 診斷**：同一症狀可能由多個 bug 共同造成
3. **LocationFudger**：用於降低位置精度以保護隱私（對 COARSE 權限的 App）
4. **呼叫鏈追蹤**：理解位置數據從 provider 到 listener 的完整路徑
