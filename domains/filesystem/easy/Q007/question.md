# Q007: StorageVolume Parcelable 實現錯誤

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: junit.framework.AssertionFailedError: Mismatch for field mPrimary
Expected: true
Actual: false
    at android.os.storage.cts.StorageManagerTest.assertStorageVolumesEquals(StorageManagerTest.java:382)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
測試將 `StorageVolume` 寫入 Parcel 後再讀取，
發現 `mPrimary` 字段的值不一致。
這導致 Parcelable 序列化/反序列化測試失敗。

## 相關日誌
```
D StorageManagerTest: Testing Parcelable contract
D StorageManagerTest: Original volume.isPrimary() = true
D StorageManagerTest: Writing to Parcel...
D StorageManagerTest: Reading from Parcel...
D StorageManagerTest: Clone volume.isPrimary() = false
E StorageManagerTest: Parcelable field mismatch detected!
```

## 提示
- 檢查 `StorageVolume.java` 中的 `writeToParcel()` 方法
- 確認寫入順序與 `CREATOR` 讀取順序一致
