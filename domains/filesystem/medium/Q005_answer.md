# Q005 答案：isAllocationSupported() 判斷邏輯與 UUID 轉換錯誤

## Bug 位置

### Bug 1: StorageManager.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1583 行
**問題:** 使用 `convert(storageUuid)` 而非 `storageUuid.toString()` 進行卷查找

### Bug 2: VolumeInfo.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 323 行
**問題:** `isSupportedFilesystem()` 檢查錯誤的檔案系統類型

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
final VolumeInfo vol = findVolumeByUuid(convert(storageUuid));

// 正確代碼
final VolumeInfo vol = findVolumeByUuid(storageUuid.toString());
```

### 修復 Bug 2:
```java
// 錯誤代碼
public boolean isSupportedFilesystem() {
    return "fat32".equals(fsType) || "exfat".equals(fsType);
}

// 正確代碼
public boolean isSupportedFilesystem() {
    return "ext4".equals(fsType) || "f2fs".equals(fsType);
}
```

## 根本原因分析

這是一個 **UUID 格式轉換 + 檔案系統判斷** 雙重錯誤：

1. `convert()` 方法用於特殊格式轉換，不應用於一般 UUID 查找
2. 檔案系統支援判斷錯誤 - FAT/exFAT 不支援 allocation，ext4/f2fs 支援

測試場景：
- 主存儲使用 ext4/f2fs
- 由於 UUID 格式錯誤，找不到卷
- 即使找到，檔案系統判斷也會返回 false

## 調試思路

1. CTS 測試調用 `isAllocationSupported()` 期望返回 true
2. 返回 false，追蹤判斷邏輯
3. 發現 `findVolumeByUuid()` 返回 null
4. 檢查 UUID 轉換，發現格式問題
5. 修復後發現 `isSupportedFilesystem()` 判斷仍錯誤
