# Q001 答案：StorageVolume 跨進程傳遞數據丟失 - 三層序列化錯誤

## Bug 位置

### Bug 1: StorageVolume.java - Parcelable 序列化順序錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageVolume.java`
**行號:** 約 385-392 行
**問題:** `writeToParcel()` 中字段順序與 `StorageVolume(Parcel)` 構造函數不匹配

### Bug 2: StorageManagerService.java - 構造參數順序錯誤
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1653-1654 行
**問題:** `buildStorageVolume()` 中 `isPrimary` 和 `isRemovable` 參數順序交換

### Bug 3: VolumeInfo.java - isPrimary() 邏輯反轉
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 298 行
**問題:** `isPrimary()` 使用 `== 0` 而非 `!= 0`

## 修復方法

### 修復 Bug 1 (StorageVolume.java):
```java
// 恢復正確的字段順序
parcel.writeInt(mExternallyManaged ? 1 : 0);
parcel.writeInt(mAllowMassStorage ? 1 : 0);
parcel.writeLong(mMaxFileSize);
parcel.writeParcelable(mUuid, flags);
```

### 修復 Bug 2 (StorageManagerService.java):
```java
// 恢復正確的參數順序
vol.isPrimary(),
vol.isRemovable(),
```

### 修復 Bug 3 (VolumeInfo.java):
```java
// 修復邏輯判斷
return (mountFlags & MOUNT_FLAG_PRIMARY) != 0;
```

## 根本原因分析

這是一個**三層數據流**錯誤：
1. **VolumeInfo** 層：`isPrimary()` 返回錯誤結果
2. **Service** 層：構造 StorageVolume 時參數順序錯誤
3. **StorageVolume** 層：Parcelable 序列化順序錯誤

數據流向：
```
VolumeInfo.isPrimary() [錯誤]
    ↓
StorageManagerService.buildStorageVolume() [參數順序錯誤]
    ↓
StorageVolume.writeToParcel() [序列化順序錯誤]
    ↓
IPC 傳輸
    ↓
StorageVolume(Parcel) [反序列化與序列化不匹配]
```

## 調試思路

1. CTS 測試檢查跨進程獲取的 StorageVolume 屬性
2. `isPrimary()` 返回錯誤值
3. 先檢查 VolumeInfo.isPrimary()，發現邏輯反轉
4. 修復後 `isRemovable()` 也錯誤，檢查 Service 層構造
5. 修復後反序列化仍錯誤，檢查 Parcelable 實現
6. 修復三處後測試通過
