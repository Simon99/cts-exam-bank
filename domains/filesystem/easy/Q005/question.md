# Q005: StorageManager isObbMounted() 總是返回 false

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testMountAndUnmountObbNormal
FAILURE: junit.framework.AssertionFailedError: OBB should be mounted
    at android.os.storage.cts.StorageManagerTest.testMountAndUnmountObbNormal(StorageManagerTest.java:115)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
OBB（Opaque Binary Blob）掛載測試失敗。
即使 OBB 文件成功掛載，`isObbMounted()` 仍然返回 `false`。

## 相關日誌
```
D StorageManager: mountObb() called for /storage/emulated/0/Android/obb/test1.obb
D StorageManager: OBB mount callback received: MOUNTED
D StorageManagerTest: Checking if OBB is mounted...
D StorageManagerTest: isObbMounted() = false  // Expected: true
E StorageManagerTest: OBB mount verification failed!
```

## 提示
- 檢查 `StorageManager.java` 中 `isObbMounted()` 的實現
- 這是一個簡單的返回值問題
