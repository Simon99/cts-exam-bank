# Q006 答案：FAT UUID 轉換格式與解析錯誤

## Bug 位置

### Bug 1: StorageManager.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/StorageManager.java`
**行號:** 約 423-424 行
**問題:** 
1. 使用 `toUpperCase` 而非 `toLowerCase`
2. 只取前 4 個字符而非全部 8 個

### Bug 2: DiskInfo.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/DiskInfo.java`
**行號:** 約 148 行
**問題:** 移除了連字號並使用大寫，破壞了格式一致性

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
final String hex = fsUuid.replace("-", "").toUpperCase(Locale.US);
return UUID.fromString(FAT_UUID_PREFIX + hex.substring(0, 4));

// 正確代碼
final String hex = fsUuid.replace("-", "").toLowerCase(Locale.US);
return UUID.fromString(FAT_UUID_PREFIX + hex);
```

### 修復 Bug 2:
```java
// 錯誤代碼
return fsUuid != null ? fsUuid.toUpperCase(Locale.US).replace("-", "") : null;

// 正確代碼
return fsUuid != null ? fsUuid.toLowerCase(Locale.US) : null;
```

## 根本原因分析

這是一個 **UUID 格式轉換** 雙重錯誤：

FAT 檔案系統 UUID 格式：`ABCD-1234`
- 正確轉換：`fafafafa-fafa-5afa-8afa-fafaabcd1234`
- 錯誤轉換：`fafafafa-fafa-5afa-8afa-fafaABCD`（大寫且截斷）

## 調試思路

1. CTS 測試掛載 FAT USB 裝置，驗證 UUID 格式
2. UUID 解析失敗或無法匹配
3. 追蹤 `convert()` 方法
4. 發現大小寫和長度問題
5. 檢查 `getNormalizedFatUuid()` 的一致性
