# Q006: CrateInfo 查詢與序列化錯誤

## 問題描述

CTS 測試 `queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate` 失敗，查詢返回空列表或數據損壞。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageStatsManagerTest#queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: queryCratesForUid returned empty list
Expected at least 1 crate after creating directory
Also: CrateInfo fields corrupted when data is returned
    at android.os.storage.cts.StorageStatsManagerTest.queryCratesForUid_addOneDirectory_shouldIncreasingOneCrate
```

## 相關日誌

```
D StorageStatsManager: queryCratesForUid: ignoring service result, returning empty
D StorageStatsService: queryCratesForUid: uid mismatch, returning null
D CrateInfo: Parcel constructor: reading icon before expiration (wrong order!)
```

## 提示

1. 檢查 Manager 層是否正確處理服務返回值
2. 追蹤 Service 層的權限和返回邏輯
3. 驗證 CrateInfo 的 Parcelable 實現
4. **問題可能分布在三個層面**

## 影響範圍

- 應用 Crate 存儲統計
- 存儲管理功能

## 難度評估

- **時間:** 40 分鐘
- **複雜度:** 高（跨三個檔案的查詢和序列化問題）
