# Q008 答案：StorageStatsManager 存儲統計數據計算鏈錯誤 - 三層計算問題

## Bug 位置

### Bug 1: StorageStatsManager.java - getTotalBytes 計算公式錯誤
**檔案路徑:** `frameworks/base/core/java/android/app/usage/StorageStatsManager.java`
**行號:** 約 95-100 行
**問題:** `getTotalBytes()` 中使用錯誤的計算公式，用減法而非直接返回

### Bug 2: StorageStatsService.java - cacheQuota 獲取邏輯錯誤
**檔案路徑:** `frameworks/base/services/usage/java/com/android/server/usage/StorageStatsService.java`
**行號:** 約 350-360 行
**問題:** 從 mCacheQuotas 獲取配額時使用錯誤的 key，導致總是返回 null/0

### Bug 3: StorageManager.java - computeStorageCacheBytes 閾值計算錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1545-1550 行
**問題:** 插值計算時分子分母順序錯誤，導致極端結果

## 修復方法

### 修復 Bug 1 (StorageStatsManager.java):
```java
// 恢復正確的計算公式
public @BytesLong long getTotalBytes(@NonNull UUID storageUuid) throws IOException {
    try {
        return mService.getTotalBytes(convert(storageUuid), mContext.getOpPackageName());
    }
    // ... 不要自己計算，直接用 service 返回的值
}
```

### 修復 Bug 2 (StorageStatsService.java):
```java
// 使用正確的 key 獲取 cacheQuota
final SparseLongArray uidQuotas = mCacheQuotas.get(volumeUuid);
// 而非 mCacheQuotas.get(packageName)
```

### 修復 Bug 3 (StorageManager.java):
```java
// 修復插值計算
double slope = (cacheReservePercentHigh - cacheReservePercentLow) * totalBytes
        / (100.0 * (storageThresholdHighBytes - storageThresholdLowBytes));
// 確保分母不為 0，且順序正確
```

## 根本原因分析

這是一個**三層數據計算**錯誤：
1. **StorageManager** 層：緩存閾值計算公式錯誤
2. **StorageStatsService** 層：配額 Map 查詢使用錯誤的 key
3. **StorageStatsManager** 層：總字節數計算使用錯誤公式

數據流向：
```
StorageManager.computeStorageCacheBytes() [計算公式錯誤]
    ↓
StorageStatsService.mCacheQuotas.get() [key 類型錯誤]
    ↓
StorageStatsService.queryStatsForPackage() [配額為 0]
    ↓
StorageStatsManager.getTotalBytes() [計算公式錯誤]
    ↓
返回錯誤的統計數據
```

## 調試思路

1. CTS 測試報告存儲統計數據完全錯誤
2. 檢查 StorageStatsManager API 調用
3. 發現 getTotalBytes 返回負數或極大值
4. 追蹤到 Service 層，發現 cacheQuota 總是 0
5. 檢查 mCacheQuotas Map，發現 key 類型不匹配
6. 進一步追蹤 computeStorageCacheBytes，發現計算公式問題
7. 修復三處後測試通過
