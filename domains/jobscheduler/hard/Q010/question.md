# Q010: JobConcurrencyManager 多作業並發時優先級反轉問題

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testHigherPriorityJobRunsFirst`

## 失敗現象
```
junit.framework.AssertionFailedError: Higher priority job (12345) didn't run in first batch: [Event{START_JOB, 12346}, Event{START_JOB, 12347}, ...]
    at android.jobscheduler.cts.JobSchedulingTest.testHigherPriorityJobRunsFirst(JobSchedulingTest.java:268)
```

## 測試環境
- 系統支援最大 64 個並發作業
- 排程 128 個 MIN 優先級作業
- 最後排程一個 DEFAULT 優先級作業
- 解除 Storage Low 約束，所有作業同時變為可執行

## 測試描述
測試作業優先級排序機制。當多個作業同時準備好執行時，較高優先級的作業應該優先執行，即使它是最後一個被排程的。

## 複現步驟
1. 設置 Storage Low 狀態，阻止作業執行
2. 排程 128 個 PRIORITY_MIN 作業
3. 排程 1 個 PRIORITY_DEFAULT 作業（最後排程）
4. 解除 Storage Low 約束
5. 驗證 DEFAULT 優先級作業是否在第一批執行

## 預期行為
PRIORITY_DEFAULT 作業應該在第一批（前 64 個）執行的作業中。

## 實際行為
作業按排程順序執行，高優先級作業被推遲。

## 難度
Hard

## 提示
1. 檢查 `JobConcurrencyManager.assignJobsToContextsLocked()` 的排序邏輯
2. 查看 `PendingJobQueue` 的優先級比較器
3. 確認 `JobSchedulerService.maybeRunPendingJobsLocked()` 的作業選擇
4. 檢查 `JobStatus.getEffectivePriority()` 的計算
5. 注意 bias 和 priority 的交互關係
