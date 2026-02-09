# Q005 答案：VolumeRecord 時間戳與持久化三層錯誤

## Bug 位置

### Bug 1: VolumeRecord.java - 序列化順序錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeRecord.java`
**行號:** 約 113-116 行
**問題:** `writeToParcel()` 中時間戳字段順序與構造函數不匹配

### Bug 2: StorageManagerService.java - XML 持久化字段混淆
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 2153-2155 行
**問題:** 寫入 XML 時使用錯誤的字段值

### Bug 3: StorageManager.java - 返回錯誤的時間戳字段
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1453 行
**問題:** `getVolumeCreationTime()` 返回 `lastSeenMillis` 而非 `createdMillis`

## 修復方法

### 修復 Bug 1 (VolumeRecord.java):
```java
dest.writeLong(createdMillis);
dest.writeLong(lastSeenMillis);
dest.writeLong(lastTrimMillis);
dest.writeLong(lastBenchMillis);
```

### 修復 Bug 2 (StorageManagerService.java):
```java
out.attribute(null, ATTR_CREATED_MILLIS, Long.toString(rec.createdMillis));
out.attribute(null, ATTR_LAST_SEEN_MILLIS, Long.toString(rec.lastSeenMillis));
out.attribute(null, ATTR_LAST_TRIM_MILLIS, Long.toString(rec.lastTrimMillis));
```

### 修復 Bug 3 (StorageManager.java):
```java
return getVolumeRecord(volume.getUuid()).createdMillis;
```

## 根本原因分析

這是一個 **時間戳數據** 三層錯誤：

1. **VolumeRecord** Parcelable 序列化順序錯誤
2. **Service** 層 XML 持久化字段映射錯誤
3. **StorageManager** 返回錯誤的時間戳字段

影響：
- 卷創建時間顯示為最後見到時間
- 重啟後時間戳被交換
- 存儲統計數據混亂

## 調試思路

1. CTS 測試檢查卷創建時間
2. 返回的時間與預期不符
3. 追蹤 `getVolumeCreationTime()`，發現返回錯誤字段
4. 修復後 Parcel 傳輸仍錯誤，檢查序列化順序
5. 修復後重啟設備仍錯誤，檢查 XML 持久化
