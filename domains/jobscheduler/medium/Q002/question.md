# Q002: BatteryConstraintTest 充電狀態變化後作業未停止

## 測試名稱
`android.jobscheduler.cts.BatteryConstraintTest#testChargingConstraintFails`

## 失敗現象
```
junit.framework.AssertionFailedError: Job with charging constraint did not stop when power removed.
    at android.jobscheduler.cts.BatteryConstraintTest.testChargingConstraintFails(BatteryConstraintTest.java:142)
```

## 測試環境
- 初始狀態：設備充電中
- 作業開始執行後拔掉電源

## 測試描述
測試需要充電的作業在拔掉電源後是否被正確停止。

## 複現步驟
1. 設定設備為充電狀態
2. 排程一個 `setRequiresCharging(true)` 的作業
3. 作業開始執行
4. 拔掉電源（設定為非充電狀態）
5. 驗證作業被停止

## 預期行為
拔掉電源後，需要充電的作業應該收到停止信號。

## 實際行為
作業在電源移除後繼續執行，沒有被停止。

## 難度
Medium

## 提示
1. 檢查 `BatteryController.maybeReportNewChargingStateLocked()` 
2. 確認狀態變化後是否正確通知了 `StateChangedListener`
3. 追蹤 `onControllerStateChanged()` 的調用鏈
