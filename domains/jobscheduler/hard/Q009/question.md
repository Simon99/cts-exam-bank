# Q009: UserInitiatedJob 背景限制應用的 UIJ 未正確停止

## 測試名稱
`android.jobscheduler.cts.UserInitiatedJobTest#testRestrictedTopToBg`

## 失敗現象
```
junit.framework.AssertionFailedError: Job did not stop after closing activity
Expected STOP_REASON_BACKGROUND_RESTRICTION but job kept running
    at android.jobscheduler.cts.UserInitiatedJobTest.testRestrictedTopToBg(UserInitiatedJobTest.java:245)
```

## 測試環境
- 測試應用被設置為 background restricted
- 應用從 TOP 狀態啟動 User-Initiated Job
- 關閉 Activity 後應用退到背景

## 測試描述
被背景限制的應用（background restricted）可以在 TOP 狀態時啟動 UIJ。但當應用離開 TOP 狀態後，因為背景限制，UIJ 應該被停止（STOP_REASON_BACKGROUND_RESTRICTION）。

## 複現步驟
1. 設置測試應用為 background restricted
2. 啟動應用的 Activity（進入 TOP 狀態）
3. 從 Activity 中排程一個 UIJ 並啟動
4. 關閉 Activity（應用退到背景）
5. 等待 UID 變為 idle 狀態
6. 驗證 UIJ 是否被停止

## 預期行為
UIJ 在應用離開 TOP 狀態後應該被停止，stop reason 為 BACKGROUND_RESTRICTION。

## 實際行為
UIJ 繼續運行，沒有被停止。

## 難度
Hard

## 提示
1. 檢查 `BackgroundJobsController` 中的 `isRestricted()` 判斷
2. 查看 `updateSingleJobRestrictionLocked()` 對 UIJ 的處理
3. 確認 `shouldTreatAsUserInitiatedJob()` 與背景限制的交互
4. 追蹤 `CONSTRAINT_BACKGROUND_NOT_RESTRICTED` 約束狀態
5. 檢查 `ForceAppStandbyListener` 的回調處理
