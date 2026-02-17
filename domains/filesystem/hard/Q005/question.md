# Q005: VolumeRecord 時間戳字段錯誤

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，卷的時間戳數據與預期不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Volume timestamp mismatch
Created: expected 1609459200000, got 1704067200000 (this is lastSeen!)
LastSeen: expected 1704067200000, got 1640995200000 (this is lastTrim!)
LastTrim: expected 1640995200000, got 1609459200000 (this is created!)
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D VolumeRecord: writeToParcel: writing timestamps in wrong order
D StorageManagerService: writeVolumeRecord: storing createdMillis=1704067200000 (lastSeen value!)
D StorageManager: getVolumeCreationTime: returning lastSeenMillis instead of createdMillis
```

## 提示

1. 比較 `writeToParcel()` 和構造函數的字段順序
2. 檢查 XML 持久化時的字段映射
3. 驗證 API 返回的字段是否正確
4. **三個層面的時間戳都可能有問題**

## 影響範圍

- 卷使用統計
- 存儲管理功能
- 自動維護排程

## 難度評估

- **時間:** 40 分鐘
- **複雜度:** 高（跨三個檔案的時間戳問題）
