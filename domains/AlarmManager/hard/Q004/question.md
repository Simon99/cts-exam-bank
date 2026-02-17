# Q004: App Standby Bucket Delay Calculation Overflow

## CTS Test
`android.alarmmanager.cts.AppStandbyTests#testBucketDelayCalculation`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm delay calculation overflow
expected: alarm delayed by ~2 hours for RARE bucket
actual: alarm fired immediately (negative delay interpreted as no delay)

at android.alarmmanager.cts.AppStandbyTests.testBucketDelayCalculation(AppStandbyTests.java:312)
```

## 現象描述
處於 RARE standby bucket 的 app 設定鬧鐘，應該有約 2 小時的延遲。
但鬧鐘立即觸發，沒有任何延遲。這發生在延遲時間計算結果為負數時。

## 提示
- 問題出在 `adjustDeliveryTimeBasedOnBucketLocked()` 的計算
- 長整數計算可能發生溢位
- 檢查延遲時間的計算和驗證

## 選項
A. 延遲計算使用 int 而非 long，導致大數值溢位變負數

B. 延遲計算時使用減法順序錯誤，導致負數結果

C. bucket 索引計算錯誤，RARE 被當成 ACTIVE 處理

D. 延遲時間的單位轉換錯誤（秒/毫秒混用）
