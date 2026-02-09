# Q007: QuotaController RESTRICTED bucket 作業配額計算錯誤

## 測試名稱
`android.jobscheduler.cts.JobThrottlingTest#testJobsInRestrictedBucket_ParoleSession`

## 失敗現象
```
junit.framework.AssertionFailedError: Parole job didn't start in RESTRICTED bucket
    at android.jobscheduler.cts.JobThrottlingTest.testJobsInRestrictedBucket_ParoleSession(JobThrottlingTest.java:614)
```

## 測試環境
- 測試應用設置為 RESTRICTED standby bucket
- 設備未充電
- 配額系統啟用（非 TARE 模式）

## 測試描述
在 RESTRICTED bucket 中的應用每天應該有一次「假釋」(parole) 執行機會，允許執行一個作業。這個測試驗證該機制是否正常運作。

## 複現步驟
1. 設置測試應用到 RESTRICTED bucket
2. 確保設備未充電
3. 排程一個普通作業
4. 強制執行作業
5. 驗證作業是否啟動（parole session）
6. 再排程另一個作業，驗證不會啟動（配額用完）

## 預期行為
第一個作業應該使用 parole session 啟動，第二個作業因配額用完而不啟動。

## 實際行為
第一個作業也無法啟動，parole session 機制失效。

## 難度
Hard

## 提示
1. 檢查 `QuotaController` 中 RESTRICTED bucket 的配額計算
2. 查看 `getTimeUntilQuotaConsumedLocked()` 方法
3. 確認 `maybeScheduleStartAlarmLocked()` 中的 parole 邏輯
4. 檢查 `isWithinQuotaLocked()` 對 RESTRICTED bucket 的特殊處理
5. 注意 `mMaxSessionCountRestricted` 配置參數
