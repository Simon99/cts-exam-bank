# Q007: DeviceStorageMonitor 低空間檢測錯誤

## 問題描述

CTS 測試 `testGetStorageVolumes` 失敗，存儲空間監控行為異常。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testGetStorageVolumes
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Storage level detection incorrect
Available: 50GB, Total: 128GB
Expected level: NORMAL
Actual level: FULL (should only be FULL when nearly empty!)
Also: Threshold calculation and path detection errors
    at android.os.storage.cts.StorageManagerTest.testGetStorageVolumes
```

## 相關日誌

```
D DeviceStorageMonitor: checkLow: usable=53687091200, checking usable >= fullBytes (inverted!)
D DeviceStorageMonitor: Level determined: FULL (wrong!)
D StorageManager: getStorageLowBytes: returning 1% instead of 10%
D VolumeInfo: getPath: returning /data/local/tmp instead of actual path
```

## 提示

1. 檢查比較運算符的方向
2. 驗證閾值計算公式
3. 追蹤路徑獲取邏輯
4. **三個層面都有問題，導致誤報**

## 影響範圍

- 低存儲空間警告
- 自動清理功能觸發
- 應用安裝限制

## 難度評估

- **時間:** 45 分鐘
- **複雜度:** 高（跨三個檔案的監控邏輯問題）
