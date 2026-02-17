# Q003: StorageVolume getState() 返回錯誤狀態

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: junit.framework.AssertionFailedError: Wrong state
Expected: MEDIA_MOUNTED
Actual: MEDIA_UNMOUNTED
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume(StorageManagerTest.java:193)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
主存儲卷的狀態應該返回 `MEDIA_MOUNTED`（已掛載），
但 `getState()` 返回了 `MEDIA_UNMOUNTED`（未掛載）。

## 相關日誌
```
D StorageManagerTest: Primary volume state: unmounted
D StorageManagerTest: Expected state: mounted
E StorageManagerTest: Volume state mismatch!
```

## 提示
- 檢查 `StorageVolume.java` 中 `getState()` 的實現
- 注意返回的字符串常量
