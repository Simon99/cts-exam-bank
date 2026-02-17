# Q003: getStorageVolume(File) 返回 null

## 問題描述

CTS 測試 `testGetStorageVolume` 失敗，使用子目錄路徑查詢存儲卷時返回 null。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolume
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: getStorageVolume returned null for valid path
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolume
```

## 相關日誌

```
D StorageManager: getStorageVolume: path=/storage/emulated/0/Download/test.txt
D StorageManager: Checking volume: path=/storage/emulated/0/internal
D StorageManager: Path mismatch: /storage/emulated/0/Download/test.txt vs /storage/emulated/0/internal
D StorageManager: getStorageVolume: returning null
```

## 提示

1. 檢查路徑匹配的邏輯（精確 vs 前綴）
2. 驗證 `getDirectory()` 返回的路徑是否正確
3. 兩個問題可能同時存在

## 影響範圍

- 檔案管理器應用
- 任何需要獲取檔案所在存儲卷的功能

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要追蹤路徑匹配邏輯）
