# Q007: StorageVolumeCallback 未正確觸發

## 問題描述

CTS 測試 `testCallback` 失敗，存儲狀態變化後回調未被觸發。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testCallback
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Callback was not triggered within timeout
    at android.os.storage.cts.StorageManagerTest.testCallback
```

## 相關日誌

```
D StorageManagerService: Volume state changed: /storage/emulated/0 unmounted -> mounted
D StorageManagerService: notifyStorageStateChanged: checking callbacks
D StorageManagerService: Skipping callback: condition not met (oldState != newState)
W StorageManagerTest: Timeout waiting for callback
```

## 提示

1. 檢查回調觸發的條件判斷
2. 驗證條件邏輯是否正確（何時應該觸發）
3. 檢查監聽器的默認實現

## 影響範圍

- 所有依賴存儲狀態通知的應用
- 檔案管理器、媒體掃描器

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解回調機制）
