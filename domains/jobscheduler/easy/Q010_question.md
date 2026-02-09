# Q010: JobSchedulingTest 最小排程配額檢查失敗

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testMinSuccessfulSchedulingQuota`

## 失敗現象
```
junit.framework.AssertionFailedError: expected:<0> but was:<1>
    at android.jobscheduler.cts.JobSchedulingTest.testMinSuccessfulSchedulingQuota(JobSchedulingTest.java:98)
```

## 測試環境
- 標準測試環境
- 持久化作業排程

## 測試描述
測試應用可以至少排程最小數量 (250) 的作業而不被阻塞。

## 複現步驟
1. 建立一個最小延遲 60 分鐘的持久化作業
2. 連續排程 250 次
3. 每次排程應返回 `RESULT_SUCCESS`

## 預期行為
所有 250 次排程都應該成功，返回 `JobScheduler.RESULT_SUCCESS` (值為 0)。

## 實際行為
某些排程返回 `RESULT_FAILURE` (值為 1)。

## 難度
Easy

## 提示
檢查 `JobSchedulerService` 中處理作業排程時的配額檢查邏輯。
