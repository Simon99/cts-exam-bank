# Q003 答案：getStorageVolume(File) 路徑匹配與卷查找錯誤

## Bug 位置

### Bug 1: StorageManager.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 1248 行
**問題:** 使用 `equals()` 而非 `startsWith()`，無法匹配子目錄

### Bug 2: StorageVolume.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageVolume.java`
**行號:** 約 278 行
**問題:** `getDirectory()` 返回錯誤路徑（附加了 "/internal"）

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
if (path.equals(volumePath.getPath())) {

// 正確代碼
if (path.startsWith(volumePath.getPath())) {
```

### 修復 Bug 2:
```java
// 錯誤代碼
public File getDirectory() {
    return mPath != null ? new File(mPath.getPath() + "/internal") : null;
}

// 正確代碼
public File getDirectory() {
    return mPath;
}
```

## 根本原因分析

這是一個**路徑匹配 + 路徑來源**雙重錯誤：

1. StorageManager 使用精確匹配而非前綴匹配
2. StorageVolume 返回了錯誤的目錄路徑

測試場景：
- 查詢 `/storage/emulated/0/Download/test.txt`
- 卷路徑返回 `/storage/emulated/0/internal`（錯誤）
- 即使用 `startsWith`，也無法匹配

## 調試思路

1. CTS 測試用子目錄檔案路徑調用 `getStorageVolume()`
2. 返回 null，期望返回對應的 StorageVolume
3. 追蹤匹配邏輯，發現使用 `equals()` 而非 `startsWith()`
4. 修復後仍然失敗，檢查 `getDirectory()` 返回值
5. 發現路徑被錯誤修改，修復後通過
