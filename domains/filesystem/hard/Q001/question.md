# Q001: StorageVolume 跨進程傳遞數據丟失

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，跨進程獲取的 StorageVolume 對象屬性與預期不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: StorageVolume properties mismatch
Expected: isPrimary=true, isRemovable=false, maxFileSize=4294967295
Actual: isPrimary=false, isRemovable=true, maxFileSize=0
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D VolumeInfo: isPrimary: mountFlags=1, checking (1 & 1) == 0 => true (BUG!)
D StorageManagerService: buildStorageVolume: primary=false, removable=true (swapped!)
D StorageVolume: writeToParcel: writing maxFileSize before booleans
D StorageVolume: Parcel constructor: reading fields in original order - mismatch!
```

## 提示

1. 追蹤數據從 VolumeInfo 到 StorageVolume 的流向
2. 檢查 Parcelable 的讀寫順序是否一致
3. 驗證構造函數的參數順序
4. **這是一個多層錯誤，需要逐層排查**

## 影響範圍

- 跨進程的存儲卷資訊傳遞
- 任何依賴 Binder IPC 獲取存儲資訊的功能

## 難度評估

- **時間:** 45 分鐘
- **複雜度:** 高（三個檔案的聯動錯誤）
