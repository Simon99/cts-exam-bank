# Q002: StorageVolume isRemovable() 邏輯反轉

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: junit.framework.AssertionFailedError: Should not be removable
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume(StorageManagerTest.java:195)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
測試在驗證 emulated storage（模擬存儲）時失敗。
對於 emulated storage，`isRemovable()` 應該返回 `false`，
但測試顯示返回了 `true`。

## 相關日誌
```
D StorageManagerTest: volume.isEmulated() = true
D StorageManagerTest: volume.isRemovable() = true  // Expected: false
E StorageManagerTest: Emulated volume should not be removable!
```

## 提示
- 檢查 `StorageVolume.java` 中 `isRemovable()` 的實現
- 注意邏輯運算符
