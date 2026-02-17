# Q003 答案：DiskInfo Parcelable 序列化三層錯誤

## Bug 位置

### Bug 1: DiskInfo.java - 序列化字段順序錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/DiskInfo.java`
**行號:** 約 178-183 行
**問題:** `writeToParcel()` 中 `flags/size` 和 `volumeCount/sysPath` 順序交換

### Bug 2: VolumeInfo.java - DiskInfo 反序列化條件反轉
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 188 行
**問題:** `readInt() == 0` 應為 `readInt() != 0`

### Bug 3: StorageManagerService.java - 返回克隆導致數據不同步
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1453-1454 行
**問題:** 使用 `keyAt(i)` 比較且返回 `clone()`

## 修復方法

### 修復 Bug 1 (DiskInfo.java):
```java
dest.writeInt(this.flags);
dest.writeLong(size);
dest.writeString(label);
dest.writeInt(volumeCount);
dest.writeString(sysPath);
```

### 修復 Bug 2 (VolumeInfo.java):
```java
if (parcel.readInt() != 0) {
```

### 修復 Bug 3 (StorageManagerService.java):
```java
if (mDisks.valueAt(i).id.equals(diskId)) {
    return mDisks.valueAt(i);
}
```

## 根本原因分析

這是一個 **Parcelable + 服務層** 三層錯誤：

1. **DiskInfo** 序列化順序與反序列化不匹配
2. **VolumeInfo** 錯誤判斷是否包含 DiskInfo
3. **Service** 層返回克隆對象，後續更新不會反映

數據流程：
```
Service.findDiskById() [返回錯誤的克隆]
    ↓
VolumeInfo(Parcel) [跳過 DiskInfo 讀取]
    ↓
DiskInfo(Parcel) [字段錯位]
```

## 調試思路

1. CTS 測試獲取 DiskInfo 並驗證屬性
2. flags 和 size 值交換
3. 追蹤 Parcelable 實現，發現順序錯誤
4. 修復後 VolumeInfo 中 disk 為 null，檢查條件判斷
5. 修復後發現 DiskInfo 屬性仍不同步，檢查 Service 層
