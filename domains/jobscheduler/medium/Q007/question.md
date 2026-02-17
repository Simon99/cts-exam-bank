# Q007: IdleConstraintTest 自動投影阻止閒置失敗

## 測試名稱
`android.jobscheduler.cts.IdleConstraintTest#testAutomotiveProjectionPreventsIdle`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with idle constraint did not fire on idle
    at android.jobscheduler.cts.IdleConstraintTest.verifyIdleState(IdleConstraintTest.java:112)
    at android.jobscheduler.cts.IdleConstraintTest.testAutomotiveProjectionPreventsIdle(IdleConstraintTest.java:178)
```

## 測試環境
- 螢幕關閉
- 自動投影 (Automotive Projection) 開啟/關閉

## 測試描述
測試當自動投影開啟時，設備不應進入閒置狀態；關閉後應進入閒置狀態。

## 複現步驟
1. 關閉螢幕
2. 開啟自動投影
3. 觸發 idle maintenance
4. 驗證設備仍為活動狀態（作業不執行）
5. 關閉自動投影
6. 觸發 idle maintenance  
7. 驗證設備進入閒置狀態（作業執行）

## 預期行為
關閉自動投影後，設備應進入閒置狀態，需要閒置的作業應該執行。

## 實際行為
關閉自動投影後，設備仍處於活動狀態，作業沒有執行。

## 難度
Medium

## 提示
1. 檢查 `IdleController` 中處理投影狀態變化的邏輯
2. 確認 `setAutomotiveProjection(false)` 後閒置狀態是否被正確更新
