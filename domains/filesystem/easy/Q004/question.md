# Q004: StorageVolume getPath() 返回 null

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetPrimaryVolume
FAILURE: java.lang.NullPointerException: Path does not match Environment's
    at android.os.storage.cts.StorageManagerTest.testGetPrimaryVolume(StorageManagerTest.java:201)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
測試期望 `volume.getPath()` 返回與 `Environment.getExternalStorageDirectory()` 
相同的路徑，但 `getPath()` 返回了 `null`，導致比較時拋出 NullPointerException。

## 相關日誌
```
D StorageManagerTest: Checking path for primary volume
D StorageManagerTest: volume.getPath() = null
D StorageManagerTest: Environment path = /storage/emulated/0
E StorageManagerTest: NullPointerException when comparing paths
```

## 提示
- 檢查 `StorageVolume.java` 中 `getPath()` 的實現
- 確認返回的是正確的路徑對象
