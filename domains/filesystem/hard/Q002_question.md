# Q002: VolumeInfo 狀態映射鏈錯誤

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，存儲卷狀態報告與實際不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Volume state mismatch
Primary volume: expected "mounted", got "unmounted"
Formatting volume: expected "unmounted", got "mounted"
Read-only volume: expected "mounted_ro", got "mounted"
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D StorageManagerService: onVolumeStateChanged: emulated;0 mounted -> forcing unmounted
D VolumeInfo: getEnvironmentForState(FORMATTING) = MEDIA_MOUNTED (wrong!)
D Environment: MEDIA_MOUNTED_READ_ONLY = "mounted" (same as MEDIA_MOUNTED!)
```

## 提示

1. 檢查狀態到環境字串的映射表
2. 追蹤 Service 層對特定卷類型的處理
3. 驗證 Environment 常量的定義
4. **三個層面都可能有問題**

## 影響範圍

- 存儲狀態報告
- 依賴狀態判斷的所有功能

## 難度評估

- **時間:** 40 分鐘
- **複雜度:** 高（跨三個檔案的狀態映射問題）
