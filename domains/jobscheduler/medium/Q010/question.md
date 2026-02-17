# Q010: JobSchedulingTest 取消執行中作業後仍有待處理作業

## 測試名稱
`android.jobscheduler.cts.JobSchedulingTest#testCancel_runningJob`

## 失敗現象
```
junit.framework.AssertionFailedError: expected:<0> but was:<1>
    at android.jobscheduler.cts.JobSchedulingTest.testCancel_runningJob(JobSchedulingTest.java:78)
```

## 測試環境
- 標準測試環境
- 加急作業正在執行中

## 測試描述
測試取消正在執行的作業後，作業應該從待處理列表中完全移除。

## 複現步驟
1. 排程一個加急作業
2. 等待作業開始執行
3. 調用 `cancelAll()` 取消所有作業
4. 等待作業停止
5. 稍等一段時間讓 JobScheduler 完成內部處理
6. 驗證 `getAllPendingJobs().size()` 為 0

## 預期行為
取消所有作業後，待處理作業列表應該為空。

## 實際行為
待處理作業列表仍有 1 個作業。

## 難度
Medium

## 提示
1. 檢查 `cancelAll()` 時對執行中作業的處理
2. 確認作業停止後是否正確從內部列表中移除
3. 檢查重新排程的邏輯是否在取消時被錯誤觸發
