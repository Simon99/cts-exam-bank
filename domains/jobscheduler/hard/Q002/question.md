# Q002: User-Initiated Job 在 Doze 模式下無法執行

## 測試名稱
`android.jobscheduler.cts.UserInitiatedJobTest#testUserInitiatedJobExecutes_DozeOn`

## 失敗現象
```
junit.framework.AssertionFailedError: UI job did not fire with Doze on.
    at android.jobscheduler.cts.UserInitiatedJobTest.testUserInitiatedJobExecutes_DozeOn
```

## 測試環境
- 螢幕關閉
- Doze 模式開啟
- 使用者發起的作業 (User-Initiated Job)

## 測試描述
測試使用者發起的作業 (User-Initiated Job, UIJ) 應該能在 Doze 模式下執行，因為這類作業是由使用者明確觸發的高優先級任務。

## 複現步驟
1. 註冊一個 User-Initiated Job
2. 關閉螢幕
3. 進入 Doze 模式
4. 驗證作業執行狀態

## 預期行為
User-Initiated Job 應該繞過 Doze 限制並正常執行。

## 實際行為
作業在 Doze 模式下被阻擋，無法執行。

## 難度
Hard

## 提示
1. 檢查 `JobStatus` 中決定作業能否在 Doze 中運行的邏輯
2. 追蹤 `canRunInDoze()` 方法的實作
3. 確認 User-Initiated Job 的豁免條件是否正確
4. 比較 Expedited Job 和 User-Initiated Job 的 Doze 豁免邏輯

## 需要分析的問題
下列哪一項最可能是造成此 bug 的原因？

A. `DeviceIdleJobsController` 的白名單過濾邏輯錯誤
B. `JobStatus.canRunInDoze()` 缺少對 User-Initiated Job 的豁免檢查
C. `QuotaController` 在 Doze 模式下的配額計算錯誤
D. `JobSchedulerService.isReadyToBeExecutedLocked()` 未正確處理 Doze 約束
