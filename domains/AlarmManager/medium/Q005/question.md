# Q005: setAlarmClock Not Showing in UI

## CTS Test
`android.alarmmanager.cts.BasicApiTests#testSetAlarmClock`

## Failure Log
```
junit.framework.AssertionFailedError: AlarmClock not visible in system UI
expected: alarm icon to appear in status bar
actual: no alarm icon visible, getNextAlarmClock returns null for other apps

at android.alarmmanager.cts.BasicApiTests.testSetAlarmClock(BasicApiTests.java:345)
```

## 現象描述
使用 `setAlarmClock()` 設定鬧鐘時鐘後，狀態列沒有顯示鬧鐘圖示。
其他 app 呼叫 `getNextAlarmClock()` 也無法取得此鬧鐘資訊。
但鬧鐘本身在時間到時會正常觸發。

## 提示
- 問題出在 `setAlarmClock()` 的 AlarmClockInfo 傳遞
- AlarmClockInfo 需要正確傳遞給 service
- 檢查呼叫 setImpl 時 AlarmClockInfo 參數的位置

## 選項
A. `setAlarmClock()` 傳遞給 setImpl 的 AlarmClockInfo 參數為 null

B. `setAlarmClock()` 沒有設定正確的 FLAG_WAKE_FROM_IDLE

C. `setAlarmClock()` 的 AlarmClockInfo 放在了錯誤的參數位置

D. `setAlarmClock()` 呼叫時沒有正確處理 showIntent
