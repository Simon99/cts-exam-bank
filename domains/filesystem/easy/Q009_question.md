# Q009: StorageManager UUID_DEFAULT 常量錯誤

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageManagerTest#testGetUuidForPath
FAILURE: junit.framework.AssertionFailedError: 
Expected: 41217664-9172-527a-b3d5-edabb50a7d69
Actual: 00000000-0000-0000-0000-000000000000
    at android.os.storage.cts.StorageManagerTest.testGetUuidForPath(StorageManagerTest.java:249)
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
`StorageManager.UUID_DEFAULT` 常量值錯誤。
這是內部存儲的標準 UUID，應該是一個固定的特定值，
但被錯誤地設置為全零 UUID。

## 相關日誌
```
D StorageManagerTest: Testing getUuidForPath for data directory
D StorageManagerTest: Expected UUID: 41217664-9172-527a-b3d5-edabb50a7d69
D StorageManagerTest: Actual UUID: 00000000-0000-0000-0000-000000000000
E StorageManagerTest: UUID_DEFAULT mismatch!
```

## 提示
- 檢查 `StorageManager.java` 中 `UUID_DEFAULT` 常量的定義
- 注意 UUID 的格式
