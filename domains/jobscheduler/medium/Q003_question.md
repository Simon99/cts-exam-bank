# Q003: JobSchedulingTest 作業優先級排序錯誤

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testHigherPriorityJobRunsFirst`

## 失敗現象
```
junit.framework.AssertionFailedError: Higher priority job (123456) didn't run in first batch: [Event{START_JOB, 123457}, Event{START_JOB, 123458}, ...]
    at android.jobscheduler.cts.JobSchedulingTest.testHigherPriorityJobRunsFirst(JobSchedulingTest.java:128)
```

## 測試環境
- 存儲狀態初始為低
- 排程多個不同優先級的作業
- 然後釋放存儲約束

## 測試描述
測試當多個作業同時準備執行時，高優先級的作業應該先執行。

## 複現步驟
1. 將存儲狀態設為低（作業無法執行）
2. 排程 128 個 `PRIORITY_MIN` 的作業
3. 排程 1 個 `PRIORITY_DEFAULT` 的作業（後排程但優先級更高）
4. 將存儲狀態設為正常
5. 驗證高優先級作業在第一批執行

## 預期行為
`PRIORITY_DEFAULT` 的作業應該在第一批（前 64 個）執行的作業中。

## 實際行為
低優先級的作業先執行，高優先級作業沒有在第一批執行。

## 難度
Medium

## 提示
1. 檢查 `JobConcurrencyManager` 或 `PendingJobQueue` 中的排序邏輯
2. 查看作業選擇執行時的優先級比較
