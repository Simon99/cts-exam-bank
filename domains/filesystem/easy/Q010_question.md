# Q010: CrateInfo getLabel() 返回空字符串

## CTS 測試失敗信息

```
Test: android.os.storage.cts.StorageStatsManagerTest#queryCratesForUid_withoutSetCrateInfo_labelShouldTheSameWithFolderName
FAILURE: junit.framework.AssertionFailedError: 
Expected: queryCratesForUid_withoutSetCrateInfo_labelShouldTheSameWithFolderName
Actual: 
    at android.os.storage.cts.StorageStatsManagerTest.queryCratesForUid_withoutSetCrateInfo_labelShouldTheSameWithFolderName
```

## 測試環境
- 設備：Pixel 7 (panther)
- Android 版本：14
- CTS 版本：android-cts-14.0_r1

## 問題描述
查詢 Crate 信息時，`getLabel()` 應該返回 crate 目錄名稱，
但實際返回了空字符串。

## 相關日誌
```
D StorageStatsManagerTest: Creating crate directory: queryCratesForUid_...
D StorageStatsManagerTest: Querying crate info...
D StorageStatsManagerTest: crateInfo.getLabel() = ""
D StorageStatsManagerTest: Expected label: queryCratesForUid_...
E StorageStatsManagerTest: Label should match folder name!
```

## 提示
- 檢查 `CrateInfo.java` 中 `getLabel()` 的實現
- Label 應該返回 `mLabel` 成員變量
