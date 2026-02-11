# Q007: filterQuotaExceededAlarms Wrong Quota Tracking

## CTS Test
`android.alarmmanager.cts.AppStandbyTests#testAlarmQuota`

## Failure Log
```
junit.framework.AssertionFailedError: Alarm quota not properly tracked
expected: 6th alarm to be deferred (quota exceeded)
actual: all 10 alarms fired immediately, quota not enforced

at android.alarmmanager.cts.AppStandbyTests.testAlarmQuota(AppStandbyTests.java:378)
```

## 現象描述
App 處於 FREQUENT bucket，每 15 分鐘最多允許 5 個鬧鐘。
測試設定了 10 個鬧鐘，前 5 個應該正常觸發，第 6-10 個應該被延遲。
但實際上 10 個鬧鐘都立即觸發了，配額沒有生效。

## 提示
- 問題出在 `filterQuotaExceededAlarms()` 的配額計數
- 需要追蹤每個 app 在時間窗口內的鬧鐘數量
- 檢查計數器的更新邏輯

## 選項
A. 配額計數器在檢查後才遞增，導致總是少算一個

B. 配額計數器使用了錯誤的 uid 作為 key

C. 配額計數器在每次鬧鐘觸發後沒有正確遞增

D. 配額時間窗口的計算邏輯錯誤，窗口過大
