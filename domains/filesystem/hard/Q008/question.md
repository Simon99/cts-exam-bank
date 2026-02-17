# Q008: StorageStatsManager 存儲統計數據計算鏈錯誤

## 問題描述

CTS 測試 `testQueryStatsForPackage` 失敗，應用程序的存儲統計數據與預期不符，總是報告錯誤的緩存大小和數據大小。

## 失敗的 CTS 測試

```
Module: CtsAppUsageTestCases
Test: android.app.usage.cts.StorageStatsManagerTest#testQueryStatsForPackage
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Storage stats mismatch for package
Expected: cacheBytes > 0, dataBytes in reasonable range
Actual: cacheBytes=0, dataBytes=9223372036854775807 (Long.MAX_VALUE!)
Also: getTotalBytes returns negative value, getFreeBytes calculation wrong
    at android.app.usage.cts.StorageStatsManagerTest.testQueryStatsForPackage
```

## 相關日誌

```
D StorageStatsManager: queryStatsForPackage: calling service
D StorageStatsService: getAppSize: cacheQuota=0 (missing from map!)
D StorageStatsService: Returning cacheBytes=0 (quota not applied!)
D StorageManager: getTotalBytes: statFs.getTotalBytes() - statFs.getAvailableBytes() (wrong formula!)
D StorageStatsManager: getFreeBytes: total - used (but total is wrong!)
```

## 提示

1. 追蹤緩存配額從 StorageManager 到 StorageStatsService 的傳遞
2. 檢查 StorageStatsService 中 cacheQuota 的獲取邏輯
3. 驗證 StorageStatsManager 中 getTotalBytes/getFreeBytes 的計算公式
4. **三層數據處理都有問題，導致統計完全錯誤**

## 影響範圍

- 設置中的存儲使用量顯示
- 應用程序的存儲統計 API
- 系統自動清理緩存的觸發

## 難度評估

- **時間:** 45 分鐘
- **複雜度:** 高（跨三個組件的數據計算錯誤）
