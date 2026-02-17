# Q002: StorageVolume 列表缺少主存儲

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，應用無法獲取到主存儲卷。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Primary storage volume not found in list
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D StorageManagerService: getStorageVolumes: user=0
D StorageManagerService: Processing volume: emulated;0 primary=true visible=true
D StorageManagerService: Filtering volume: skipping due to filter condition
W StorageManagerTest: Expected at least one primary volume, found 0
```

## 提示

1. 追蹤 `getStorageVolumes()` 的實現邏輯
2. 檢查過濾條件是否正確
3. 驗證 `isPrimary()` 的行為

## 影響範圍

- 所有需要存取主存儲的應用程式
- 檔案選擇器、相機應用等

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解過濾邏輯和屬性方法）
