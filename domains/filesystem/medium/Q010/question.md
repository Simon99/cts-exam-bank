# Q010: OBB 錯誤包名驗證失敗

## 問題描述

CTS 測試 `testAttemptMountObbWrongPackage` 失敗，使用錯誤包名掛載 OBB 時應被拒絕但卻成功了。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testAttemptMountObbWrongPackage
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Expected SecurityException when mounting OBB with wrong package
    at android.os.storage.cts.StorageManagerTest.testAttemptMountObbWrongPackage
```

## 相關日誌

```
D StorageManagerService: mountObb: path=/data/local/tmp/test.obb
D StorageManagerService: OBB packageName=com.correct.app, caller=com.wrong.app
D StorageManagerService: isCallerAllowedToMountObb: packages don't match, returning true (BUG!)
D ObbInfo: getPackageName: returning lowercase "com.correct.app"
```

## 提示

1. 檢查包名比較的邏輯運算符
2. 驗證 `getPackageName()` 的返回值
3. 注意這是安全相關的 bug

## 影響範圍

- OBB 存取安全性
- 應用數據隔離

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解安全檢查邏輯）
