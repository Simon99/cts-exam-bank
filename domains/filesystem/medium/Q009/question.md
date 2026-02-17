# Q009: VolumeInfo 狀態廣播錯誤

## 問題描述

CTS 測試 `testVolumeStateChangeBroadcast` 失敗，卷狀態變化廣播類型與預期不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testVolumeStateChangeBroadcast
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Expected broadcast ACTION_MEDIA_MOUNTED
Actual: ACTION_MEDIA_UNMOUNTED
    at android.os.storage.cts.StorageManagerTest.testVolumeStateChangeBroadcast
```

## 相關日誌

```
D StorageManagerService: Volume state changed: unmounted -> mounted_read_only
D VolumeInfo: getEnvironmentForState(MOUNTED_READ_ONLY) = MEDIA_MOUNTED
D StorageManagerService: getBroadcastForEnvironment using oldState: unmounted
D StorageManagerService: Sending broadcast: ACTION_MEDIA_UNMOUNTED (wrong!)
```

## 提示

1. 檢查狀態到環境的映射表
2. 追蹤廣播發送使用的狀態參數
3. 注意 oldState vs newState 的使用

## 影響範圍

- 媒體掃描器
- 存儲狀態監聽應用

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解狀態映射機制）
