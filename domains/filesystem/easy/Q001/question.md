# Q001: StorageVolume isPrimary() 返回錯誤值

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: junit.framework.AssertionFailedError: Should be primary
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume(StorageManagerTest.java:189)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
執行 CTS filesystem 測試時，`testGetPrimaryVolume` 測試失敗。
測試期望 `getPrimaryStorageVolume()` 返回的 volume 應該 `isPrimary() == true`，
但實際返回 `false`。

## 相關日誌
```
D StorageManager: getPrimaryStorageVolume returned volume with path=/storage/emulated/0
D StorageManagerTest: volume.isPrimary() = false
```

## 提示
- 檢查 `StorageVolume.java` 中 `isPrimary()` 的實現
- 這是一個簡單的返回值問題
