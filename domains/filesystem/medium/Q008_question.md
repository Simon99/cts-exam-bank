# Q008: Crate 目錄查詢返回錯誤數量

## 問題描述

CTS 測試 `queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate` 失敗，新增目錄後 crate 數量不正確。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageStatsManagerTest#queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Expected crate count to increase by 1
Before: 5, After: 7 (expected 6)
    at android.os.storage.cts.StorageStatsManagerTest.queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate
```

## 相關日誌

```
D StorageStatsService: queryCratesForUid: uid=10001
D StorageStatsService: Processing directory: /data/user/0/com.test/crate/mydir
D StorageStatsService: Creating CrateInfo with packageName=null
D CrateInfo: fromFile: invalid dir, returning empty CrateInfo
```

## 提示

1. 追蹤 CrateInfo 的創建過程
2. 檢查參數傳遞是否正確
3. 驗證空值處理邏輯

## 影響範圍

- 應用存儲統計
- 存儲管理功能

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要追蹤對象構造流程）
