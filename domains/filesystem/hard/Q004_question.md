# Q004: StorageManager UUID 轉換邏輯錯誤

## 問題描述

CTS 測試 `testGetUuidForPath` 失敗，路徑到 UUID 的映射返回錯誤結果。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetUuidForPath
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: UUID mismatch for path
Path: /storage/1234-5678/test.txt
Expected UUID: 1234-5678
Actual UUID: 41217664-9172-527a-b3d5-edabb50a7d69 (primary storage UUID)
    at android.os.storage.cts.StorageManagerTest.testGetUuidForPath
```

## 相關日誌

```
D StorageManager: getUuidForPath: path=/storage/1234-5678/test.txt
D StorageManager: Using primary storage instead of path lookup (BUG!)
D VolumeInfo: getFsUuid: returning "1234-5678" as "1234-5678" (uppercase)
D StorageManagerService: findVolumeByUuid: match found, returning null (BUG!)
```

## 提示

1. 檢查 `getUuidForPath()` 是否使用輸入路徑
2. 追蹤 UUID 比較的大小寫處理
3. 驗證 Service 層的卷查找邏輯
4. **三層都有問題，需要逐層修復**

## 影響範圍

- 存儲卷識別
- 應用數據位置追蹤

## 難度評估

- **時間:** 40 分鐘
- **複雜度:** 高（跨三個檔案的 UUID 處理問題）
