# Q009 答案：StorageVolume UUID 和狀態判斷三層錯誤

## Bug 位置

### Bug 1: StorageVolume.java - getState() 狀態判斷條件錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageVolume.java`
**行號:** 約 380-390 行
**問題:** `getState()` 中的條件判斷邏輯錯誤，mounted 狀態被錯誤地映射

### Bug 2: StorageVolume.java - getStorageUuid() 條件反轉
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageVolume.java`
**行號:** 約 340-345 行
**問題:** 返回 mUuid 的條件使用 `== null` 而非 `!= null`

### Bug 3: VolumeInfo.java - getNormalizedFsUuid() 大小寫處理錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 290-295 行
**問題:** 使用 `toUpperCase()` 而非 `toLowerCase()`，導致 UUID 格式不符規範

## 修復方法

### 修復 Bug 1 (StorageVolume.java - getState):
```java
public String getState() {
    // 恢復正確的狀態返回
    return mState;  // 而非 Environment.MEDIA_UNKNOWN
}
```

### 修復 Bug 2 (StorageVolume.java - getStorageUuid):
```java
public @Nullable UUID getStorageUuid() {
    return mUuid;  // 直接返回，不要加錯誤的 null 檢查
}
```

### 修復 Bug 3 (VolumeInfo.java):
```java
public @Nullable String getNormalizedFsUuid() {
    return fsUuid != null ? fsUuid.toLowerCase(Locale.US) : null;
    // 而非 toUpperCase()
}
```

## 根本原因分析

這是一個**三層狀態/UUID 處理**錯誤：
1. **StorageVolume.getState()** 層：狀態映射邏輯錯誤
2. **StorageVolume.getStorageUuid()** 層：null 檢查條件反轉
3. **VolumeInfo.getNormalizedFsUuid()** 層：大小寫轉換方向錯誤

數據流向：
```
VolumeInfo.getNormalizedFsUuid() [大小寫錯誤]
    ↓
StorageVolume 構造 [收到錯誤格式的 UUID]
    ↓
StorageVolume.getStorageUuid() [條件反轉，返回 null]
    ↓
StorageVolume.getState() [狀態映射錯誤]
    ↓
CTS 測試收到錯誤的存儲卷信息
```

## 調試思路

1. CTS 測試報告 storageUuid 為 null 且 state 為 UNKNOWN
2. 檢查 StorageVolume.getStorageUuid()，發現條件判斷反轉
3. 追蹤 mUuid 的來源，發現 VolumeInfo 的 UUID 大小寫不符
4. 檢查 getState()，發現狀態映射有問題
5. 修復三處後，UUID 和狀態正確返回
6. MediaStore 可以正確識別存儲卷
