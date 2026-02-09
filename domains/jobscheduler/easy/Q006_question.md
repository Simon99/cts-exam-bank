# Q006: IdleConstraintTest 閒置狀態切換失敗

## 測試名稱
`android.jobscheduler.cts.IdleConstraintTest#testDeviceChangeIdleActiveState`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with idle constraint did not fire on idle
    at android.jobscheduler.cts.IdleConstraintTest.verifyIdleState(IdleConstraintTest.java:112)
    at android.jobscheduler.cts.IdleConstraintTest.testDeviceChangeIdleActiveState(IdleConstraintTest.java:128)
```

## 測試環境
- 螢幕關閉
- 觸發了 idle maintenance

## 測試描述
測試設備閒置狀態的切換。當螢幕關閉一段時間後，設備應該進入閒置狀態。

## 複現步驟
1. 開啟螢幕，驗證設備為活動狀態
2. 關閉螢幕
3. 觸發 idle maintenance
4. 驗證設備為閒置狀態

## 預期行為
螢幕關閉並觸發 idle maintenance 後，設備應該進入閒置狀態，需要設備閒置的作業應該可以執行。

## 實際行為
設備始終保持活動狀態，閒置約束的作業無法執行。

## 難度
Easy

## 提示
檢查 `IdleController` 或相關的閒置追蹤器中，螢幕狀態變化時的狀態更新邏輯。
