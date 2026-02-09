# Q008: StorageVolume describeContents() 返回錯誤值

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: junit.framework.AssertionFailedError: Wrong describeContents
Expected: 0
Actual: 1
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume(StorageManagerTest.java:208)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
`Parcelable` 接口的 `describeContents()` 方法返回了錯誤的值。
對於沒有特殊對象（如 FileDescriptor）的普通 Parcelable，
應該返回 0，但實際返回了 1。

## 相關日誌
```
D StorageManagerTest: Testing describeContents()
D StorageManagerTest: volume.describeContents() = 1
D StorageManagerTest: Expected: 0
E StorageManagerTest: describeContents mismatch!
```

## 提示
- 檢查 `StorageVolume.java` 中 `describeContents()` 的實現
- 這是 Parcelable 接口的標準方法
