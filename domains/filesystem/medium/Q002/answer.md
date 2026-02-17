# Q002 答案：StorageVolume 列表過濾與主存儲標記錯誤

## Bug 位置

### Bug 1: StorageManagerService.java
**檔案路徑:** `frameworks/base/services/core/java/com/android/server/StorageManagerService.java`
**行號:** 約 1853 行
**問題:** 過濾條件錯誤排除了主存儲卷（`!vol.isPrimary()`）

### Bug 2: StorageVolume.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageVolume.java`
**行號:** 約 248 行
**問題:** `isPrimary()` 返回值被反轉（`!mPrimary`）

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
if (vol.isVisibleForUser(userId) && !vol.isPrimary()) {

// 正確代碼
if (vol.isVisibleForUser(userId)) {
```

### 修復 Bug 2:
```java
// 錯誤代碼
public boolean isPrimary() {
    return !mPrimary;
}

// 正確代碼
public boolean isPrimary() {
    return mPrimary;
}
```

## 根本原因分析

這兩個 bug 構成了一個**雙重邏輯錯誤**：

1. Service 層嘗試過濾掉「非主存儲」，但條件寫反了（`!vol.isPrimary()`）
2. `isPrimary()` 本身返回值也被反轉

由於兩個反轉，實際效果變得複雜：
- 當 mPrimary=true 時，`isPrimary()` 返回 false
- `!vol.isPrimary()` 變成 true，主存儲被錯誤地排除

## 調試思路

1. CTS 測試檢查 `getStorageVolumes()` 返回的列表
2. 發現主存儲卷未包含在列表中
3. 追蹤 `getStorageVolumes()` 實現，發現過濾條件
4. 檢查 `isPrimary()` 返回值，發現邏輯反轉
5. 修復兩處錯誤後測試通過
