# Q002: UserInitiatedJobTest 使用者發起的作業 Doze 模式下無法執行

## 測試名稱
`android.jobscheduler.cts.ConnectivityConstraintTest#testUserInitiatedJobExecutes_DozeOn`

## 失敗現象
```
junit.framework.AssertionFailedError: UI job requiring connectivity did not fire with Doze on.
    at android.jobscheduler.cts.ConnectivityConstraintTest.testUserInitiatedJobExecutes_DozeOn(ConnectivityConstraintTest.java:350)
```

## 測試環境
- 螢幕關閉
- Doze 模式開啟
- 使用者發起的作業需要網絡

## 測試描述
測試使用者發起的作業 (User-Initiated Job) 應該能在 Doze 模式下執行。

## 複現步驟
1. 啟用所有網絡
2. 關閉螢幕
3. 進入 Doze 模式
4. 通過通知點擊觸發使用者發起的作業排程
5. 驗證作業執行

## 預期行為
使用者發起的作業即使在 Doze 模式下也應該執行。

## 實際行為
作業在 Doze 模式下被阻擋，無法執行。

## 難度
Hard

## 提示
1. 檢查 `DeviceIdleJobsController` 中對使用者發起作業的白名單處理
2. 檢查 `QuotaController` 中的 Doze 模式判斷
3. 確認 `JobSchedulerService.isJobReady()` 對 user-initiated 的特殊處理
4. 追蹤通知點擊到作業排程的完整流程
