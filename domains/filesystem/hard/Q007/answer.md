# Q007 答案：DeviceStorageMonitor 低空間檢測三層錯誤

## Bug 位置

### Bug 1: DeviceStorageMonitorService.java - 比較邏輯反轉
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/storage/DeviceStorageMonitorService.java`
**行號:** 約 228-232 行
**問題:** 使用 `>=` 而非 `<=`，且 FULL 和 LOW 判斷交換

### Bug 2: StorageManager.java - 閾值計算錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1653 行
**問題:** 使用 `min` 和 1% 而非 `max` 和 10%

### Bug 3: VolumeInfo.java - 路徑返回錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 313 行
**問題:** 總是返回 `/data/local/tmp` 而非實際路徑

## 修復方法

### 修復 Bug 1 (DeviceStorageMonitorService.java):
```java
if (usableBytes <= fullBytes) {
    newLevel = State.LEVEL_FULL;
} else if (usableBytes <= lowBytes) {
    newLevel = State.LEVEL_LOW;
} else {
    newLevel = State.LEVEL_NORMAL;
}
```

### 修復 Bug 2 (StorageManager.java):
```java
return Math.max(path.getTotalSpace() / 10, DEFAULT_LOW_THRESHOLD);
```

### 修復 Bug 3 (VolumeInfo.java):
```java
return path != null ? new File(path) : null;
```

## 根本原因分析

這是一個 **存儲監控** 三層錯誤：

1. **Monitor** 層比較邏輯完全反轉
2. **StorageManager** 層閾值計算過低
3. **VolumeInfo** 層返回錯誤路徑

影響：
- 大量可用空間時誤報低空間
- 閾值過低導致警告太晚
- 路徑錯誤導致檢測錯誤的位置

## 調試思路

1. CTS 測試檢查低空間警告
2. 有足夠空間時收到低空間通知
3. 追蹤 checkLow() 邏輯，發現比較反轉
4. 修復後閾值計算不正確，檢查 getStorageLowBytes
5. 修復後檢測的路徑錯誤，追蹤 getPath()
