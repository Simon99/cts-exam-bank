# Q008: JobSchedulingTest 待處理作業原因錯誤

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testPendingJobReason_minimumLatency`

## 失敗現象
```
junit.framework.AssertionFailedError: expected:<5> but was:<0>
    at android.jobscheduler.cts.JobSchedulingTest.testPendingJobReason_minimumLatency(JobSchedulingTest.java:295)
```

## 測試環境
- 標準測試環境
- 作業設有最小延遲 1 小時

## 測試描述
測試 `getPendingJobReason()` 應該返回正確的原因。設有最小延遲的作業應該返回 `PENDING_JOB_REASON_CONSTRAINT_MINIMUM_LATENCY`。

## 複現步驟
1. 排程一個設有 1 小時最小延遲的作業
2. 調用 `mJobScheduler.getPendingJobReason(JOB_ID)`
3. 驗證返回值為 `PENDING_JOB_REASON_CONSTRAINT_MINIMUM_LATENCY` (值為 5)

## 預期行為
`getPendingJobReason()` 應返回 5 (PENDING_JOB_REASON_CONSTRAINT_MINIMUM_LATENCY)。

## 實際行為
返回 0 (PENDING_JOB_REASON_UNDEFINED) 或其他錯誤值。

## 難度
Medium

## 提示
1. 檢查 `JobSchedulerService` 中 `getPendingJobReason()` 的實現
2. 確認延遲約束的檢測邏輯
