# Q008 答案：Crate 目錄查詢過濾與 CrateInfo 構造錯誤

## Bug 位置

### Bug 1: StorageStatsService.java
**檔案路徑:** `frameworks/base/services/usage/java/com/android/server/usage/StorageStatsService.java`
**行號:** 約 583 行
**問題:** `CrateInfo.fromFile()` 傳入 `null` 而非 `packageName`

### Bug 2: CrateInfo.java
**檔案路徑:** `frameworks/base/core/java/android/os/storage/CrateInfo.java`
**行號:** 約 98 行
**問題:** 無效目錄返回空 CrateInfo 而非 null

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
result.add(CrateInfo.fromFile(dir, null));

// 正確代碼
result.add(CrateInfo.fromFile(dir, packageName));
```

### 修復 Bug 2:
```java
// 錯誤代碼
if (dir == null || !dir.isDirectory()) {
    return new CrateInfo("", null, 0);
}

// 正確代碼
if (dir == null || !dir.isDirectory()) {
    return null;
}
```

## 根本原因分析

這是一個 **參數傳遞 + 空值處理** 雙重錯誤：

1. Service 層忘記傳遞 packageName，導致所有 CrateInfo 的包名為 null
2. 工廠方法返回空對象而非 null，導致列表包含無效項目

測試場景：
- 查詢特定 UID 的 crate 目錄
- 返回的 CrateInfo 包名為 null，無法匹配
- 空目錄產生空白 CrateInfo 增加數量

## 調試思路

1. CTS 測試創建目錄後查詢 crate 數量
2. 數量不正確或包名匹配失敗
3. 追蹤 `queryCratesForUid()` 實現
4. 發現 packageName 參數錯誤傳 null
5. 檢查 `fromFile()` 返回值處理
