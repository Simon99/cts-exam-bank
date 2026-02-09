# Q006 答案：CrateInfo Parcelable 與 Service 查詢三層錯誤

## Bug 位置

### Bug 1: CrateInfo.java - Parcel 讀取順序和條件錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/CrateInfo.java`
**行號:** 約 87-92 行
**問題:** 讀取順序與 writeToParcel 不匹配，且 Icon 讀取條件反轉

### Bug 2: StorageStatsService.java - 權限檢查和返回值錯誤
**檔案路徑:** `frameworks/base/services/usage/java/com/android/server/usage/StorageStatsService.java`
**行號:** 約 622-624 行
**問題:** 跳過權限檢查，非擁有者返回空列表，擁有者返回 null

### Bug 3: StorageStatsManager.java - 結果處理錯誤
**檔案路徑:** `frameworks/base/core/java/android/app/usage/StorageStatsManager.java`
**行號:** 約 188 行
**問題:** 忽略服務返回值，總是返回空列表

## 修復方法

### 修復 Bug 1 (CrateInfo.java):
```java
mLabel = in.readString();
mExpiration = in.readLong();
if (in.readInt() != 0) {
    mIcon = in.readParcelable(Icon.class.getClassLoader(), Icon.class);
} else {
    mIcon = null;
}
```

### 修復 Bug 2 (StorageStatsService.java):
```java
enforceCrossUserPermission(Binder.getCallingUid(), uid);
return new ParceledListSlice<>(getCratesForUid(volumeUuid, uid));
```

### 修復 Bug 3 (StorageStatsManager.java):
```java
return slice != null ? slice.getList() : Collections.emptyList();
```

## 根本原因分析

這是一個 **Crate 查詢** 三層錯誤：

1. **CrateInfo** Parcelable 反序列化順序錯誤
2. **Service** 層權限處理和返回值錯誤
3. **Manager** 層忽略服務返回值

影響：
- queryCratesForUid 總是返回空
- 即使返回數據，反序列化也會失敗

## 調試思路

1. CTS 測試調用 queryCratesForUid
2. 返回空列表
3. 追蹤 StorageStatsManager，發現忽略返回值
4. 修復後仍返回空，檢查 Service 層
5. 修復後數據損壞，檢查 Parcelable 實現
