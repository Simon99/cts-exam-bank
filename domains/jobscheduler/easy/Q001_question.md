# Q001: BatteryConstraintTest 充電約束失敗

## 測試名稱
`android.jobscheduler.cts.BatteryConstraintTest#testChargingConstraintExecutes`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with charging constraint did not fire on power.
    at android.jobscheduler.cts.BatteryConstraintTest.testChargingConstraintExecutes(BatteryConstraintTest.java:95)
```

## 測試環境
- 設備已連接電源
- 電池電量充足 (100%)
- 設備充電狀態為 true

## 測試描述
測試排程一個需要設備正在充電的作業，當電池報告已插入電源時，作業應該執行。

## 複現步驟
1. 將設備連接電源
2. 設定電池電量為 100%
3. 排程一個 `setRequiresCharging(true)` 的作業
4. 等待作業執行

## 預期行為
作業應該在設備連接電源且充電時執行。

## 實際行為
作業沒有執行，超時等待後測試失敗。

## 難度
Easy

## 提示
檢查 `BatteryController` 中判斷充電狀態的邏輯。
