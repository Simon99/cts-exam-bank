# Q004 答案：StorageManager UUID 轉換三層邏輯錯誤

## Bug 位置

### Bug 1: StorageManager.java - 路徑到 UUID 映射錯誤
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1323-1326 行
**問題:** 使用 `getPrimaryStorageVolume()` 而非 `getStorageVolume(path)`

### Bug 2: VolumeInfo.java - UUID 大小寫轉換
**檔案路徑:** `frameworks/base/core/java/android/os/storage/VolumeInfo.java`
**行號:** 約 255 行
**問題:** `getFsUuid()` 返回大寫版本，破壞比較

### Bug 3: StorageManagerService.java - UUID 查找邏輯錯誤
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1523-1525 行
**問題:** 匹配成功時返回 null 而非卷

## 修復方法

### 修復 Bug 1 (StorageManager.java):
```java
final StorageVolume volume = getStorageVolume(path);
if (volume == null) {
    throw new IOException("Path not in any storage volume: " + path);
}
```

### 修復 Bug 2 (VolumeInfo.java):
```java
public String getFsUuid() {
    return fsUuid;
}
```

### 修復 Bug 3 (StorageManagerService.java):
```java
if (uuid.equalsIgnoreCase(mVolumes.valueAt(i).fsUuid)) {
    return mVolumes.valueAt(i);
}
```

## 根本原因分析

這是一個 **UUID 路徑映射** 三層錯誤：

1. **StorageManager** 層忽略輸入路徑，總是返回主存儲 UUID
2. **VolumeInfo** 層改變 UUID 大小寫
3. **Service** 層匹配成功時返回 null

錯誤連鎖：
- 用 SD 卡路徑查詢 UUID
- 返回主存儲的 UUID（錯誤）
- 如果嘗試反向查找，Service 返回 null

## 調試思路

1. CTS 測試用 SD 卡路徑調用 `getUuidForPath()`
2. 返回主存儲 UUID 而非 SD 卡 UUID
3. 追蹤 `getUuidForPath()` 實現，發現不用輸入路徑
4. 修復後仍失敗，檢查 UUID 比較（大小寫問題）
5. 修復後 Service 層返回 null，檢查返回邏輯
