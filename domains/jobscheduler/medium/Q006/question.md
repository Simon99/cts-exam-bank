# Q006: JobSchedulingTest 命名空間作業隔離失敗

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testNamespace_schedule`

## 失敗現象
```
junit.framework.AssertionFailedError: expected:<1> but was:<2>
    at android.jobscheduler.cts.JobSchedulingTest.testNamespace_schedule(JobSchedulingTest.java:245)
```

## 測試環境
- 標準測試環境
- 使用命名空間 A 和 B

## 測試描述
測試使用不同命名空間的 JobScheduler 實例應該獨立管理各自的作業。

## 複現步驟
1. 獲取命名空間 "A" 的 JobScheduler 實例
2. 獲取命名空間 "B" 的 JobScheduler 實例
3. 在兩個命名空間中排程相同 ID 的作業（但配置不同）
4. 驗證各命名空間只能看到自己的作業
5. 驗證 `getAllPendingJobs()` 只返回當前命名空間的作業

## 預期行為
`jsA.getAllPendingJobs()` 應該只返回 1 個作業，`jsB.getAllPendingJobs()` 也應該只返回 1 個作業。

## 實際行為
`getAllPendingJobs()` 返回了 2 個作業，說明命名空間沒有正確隔離。

## 難度
Medium

## 提示
1. 檢查 `JobSchedulerService` 中命名空間過濾的邏輯
2. 確認 `getAllPendingJobs()` 是否正確使用了命名空間過濾
