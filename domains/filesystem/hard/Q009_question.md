# Q009: StorageVolume UUID 和狀態判斷三層錯誤

## 問題描述

CTS 測試 `testGetPrimaryVolume` 失敗，主存儲卷的 UUID 和狀態信息不正確，導致 MediaStore 無法正確識別存儲卷。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Primary volume validation failed
Expected: isPrimary=true, state=MEDIA_MOUNTED, storageUuid=UUID_DEFAULT
Actual: isPrimary=true, state=MEDIA_UNKNOWN, storageUuid=null
Also: getMediaStoreVolumeName returns null instead of VOLUME_EXTERNAL_PRIMARY
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume
```

## 相關日誌

```
D StorageVolume: getState: mState="mounted" but returning MEDIA_UNKNOWN (mapping missing!)
D StorageVolume: getStorageUuid: mUuid is valid but returning null (condition inverted!)
D VolumeInfo: getNormalizedFsUuid: returning uppercase instead of lowercase
D StorageManager: convert(uuid): catching NumberFormatException silently, returning null
```

## 提示

1. 檢查 StorageVolume 的 getState() 狀態映射邏輯
2. 追蹤 getStorageUuid() 的條件判斷
3. 驗證 VolumeInfo.getNormalizedFsUuid() 的大小寫轉換
4. **三個層面的判斷條件都有問題**

## 影響範圍

- MediaStore 的存儲卷識別
- 應用程序的外部存儲訪問
- 文件管理器的存儲卷顯示

## 難度評估

- **時間:** 45 分鐘
- **複雜度:** 高（UUID 和狀態的多層判斷錯誤）
