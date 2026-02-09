# Q005: ExpeditedJobTest Doze 模式下加急作業未正確繞過設備空閒限制

## 測試名稱
`android.jobscheduler.cts.JobThrottlingTest#testExpeditedJobBypassesDeviceIdle`

## 失敗現象
```
junit.framework.AssertionFailedError: Job did not start after scheduling
    at android.jobscheduler.cts.JobThrottlingTest.testExpeditedJobBypassesDeviceIdle(JobThrottlingTest.java:418)
```

## 測試環境
- 設備進入 Doze（Device Idle）模式
- 排程一個加急作業（Expedited Job）
- 期望加急作業能夠繞過 Doze 限制執行

## 測試描述
測試加急作業（EJ）在設備進入 Doze 模式時應該能夠繞過設備空閒限制正常執行。這是 EJ 的重要特性之一。

## 複現步驟
1. 使用 `adb shell cmd deviceidle force-idle` 進入 Doze 模式
2. 排程一個加急作業（`setExpedited(true)`）
3. 強制執行作業 `adb shell cmd jobscheduler run`
4. 驗證作業是否啟動

## 預期行為
加急作業在 Doze 模式下應該能夠正常啟動執行。

## 實際行為
作業未能啟動，被 Doze 模式阻擋。

## 難度
Hard

## 提示
1. 檢查 `DeviceIdleJobsController` 中對加急作業的特殊處理
2. 查看 `updateTaskStateLocked()` 方法中的 `allowInIdle` 判斷邏輯
3. 確認 `isRequestedExpeditedJob()` 的檢查是否被正確納入
4. 追蹤 `CONSTRAINT_DEVICE_NOT_DOZING` 約束的設置邏輯
