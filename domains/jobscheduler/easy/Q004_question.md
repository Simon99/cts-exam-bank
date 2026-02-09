# Q004: BatteryConstraintTest 電量不低約束失敗

## 測試名稱
`android.jobscheduler.cts.BatteryConstraintTest#testBatteryNotLowConstraintExecutes_withPower`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with battery not low constraint did not fire on power.
    at android.jobscheduler.cts.BatteryConstraintTest.testBatteryNotLowConstraintExecutes_withPower(BatteryConstraintTest.java:108)
```

## 測試環境
- 設備已連接電源
- 電池電量為 100%
- 電池狀態為充電中

## 測試描述
測試排程一個需要電池不低的作業，當設備插入電源且電池電量充足時，作業應該執行。

## 複現步驟
1. 設定電池狀態為充電中
2. 設定電池電量為 100%
3. 排程一個 `setRequiresBatteryNotLow(true)` 的作業
4. 等待作業執行

## 預期行為
電池電量充足且正在充電時，作業應該執行。

## 實際行為
作業沒有執行，電池不低約束顯示為不滿足。

## 難度
Easy

## 提示
檢查 `BatteryController` 中 `setBatteryNotLowConstraintSatisfied` 的調用參數。
