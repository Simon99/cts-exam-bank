# Q007: Remove Alarm Doesn't Clear All Matching

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testRemoveMultipleAlarms`

## Failure Log
```
junit.framework.AssertionFailedError: Not all matching alarms removed
expected: 0 alarms remaining after cancel
actual: 2 alarms still scheduled

at android.alarmmanager.cts.BasicApiTests.testRemoveMultipleAlarms(BasicApiTests.java:402)
```

## 現象描述
App 設定了 5 個使用相同 PendingIntent 的鬧鐘（不同觸發時間），
呼叫 `cancel()` 後，應該取消全部 5 個，但只取消了最先設定的 3 個。
剩餘 2 個鬧鐘仍會在預定時間觸發。

## 提示
- 問題出在 `AlarmManagerService.java` 的 `removeLocked()` 方法
- 移除時需要遍歷所有 batch 中的鬧鐘
- 檢查迴圈的終止條件

## 選項
A. `removeLocked()` 使用 `break` 而非 `continue` 導致提早退出迴圈

B. `removeLocked()` 只檢查第一個 batch，沒有遍歷所有 batch

C. `removeLocked()` 移除後沒有正確調整迭代器

D. `removeLocked()` 的匹配邏輯有問題，後面的鬧鐘匹配失敗
