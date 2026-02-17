# Q007: TimingConstraintsTest 週期性作業重新排程失敗

## 測試名稱
`android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic`

## 失敗現象
```
junit.framework.AssertionFailedError: Timed out waiting for periodic jobs to execute
    at android.jobscheduler.cts.TimingConstraintsTest.testSchedulePeriodic(TimingConstraintsTest.java:47)
```

## 測試環境
- 標準測試環境
- 週期設為最小週期 (15 分鐘)

## 測試描述
測試週期性作業的排程和執行。作業執行後應該自動重新排程。

## 複現步驟
1. 建立一個週期為 `JobInfo.getMinPeriodMillis()` 的週期性作業
2. 排程作業
3. 觸發作業執行
4. 驗證作業執行
5. 驗證作業被重新排程且處於等待狀態

## 預期行為
週期性作業執行後應該自動重新排程，狀態為 waiting 且 not ready。

## 實際行為
作業沒有被正確排程或無法執行。

## 難度
Easy

## 提示
檢查週期性作業的 `isPeriodic()` 判斷邏輯。
