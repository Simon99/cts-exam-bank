# Q003: DiskInfo Parcelable 序列化錯誤

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，獲取的 DiskInfo 屬性值與預期不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: DiskInfo properties mismatch
Expected: flags=5, size=32212254720, volumeCount=1
Actual: flags=32212254720, size=5, volumeCount=null (parsed as string)
VolumeInfo.disk is unexpectedly null
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D DiskInfo: writeToParcel: writing size before flags
D DiskInfo: constructor(Parcel): reading flags=32212254720 (should be 5)
D VolumeInfo: constructor(Parcel): disk marker=0, skipping DiskInfo (wrong!)
D StorageManagerService: findDiskById: returning clone of disk
```

## 提示

1. 比較 `writeToParcel()` 和 `DiskInfo(Parcel)` 的字段順序
2. 檢查 VolumeInfo 中讀取 DiskInfo 的條件
3. 追蹤 Service 層的 DiskInfo 查找邏輯
4. **三個檔案都有問題**

## 影響範圍

- 磁碟資訊查詢
- USB/SD 卡識別

## 難度評估

- **時間:** 40 分鐘
- **複雜度:** 高（跨三層的序列化問題）
