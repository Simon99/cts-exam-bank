# Q005 Answer: setAlarmClock Not Showing in UI

## 正確答案
**A. `setAlarmClock()` 傳遞給 setImpl 的 AlarmClockInfo 參數為 null**

## 問題根因
在 `AlarmManager.java` 的 `setAlarmClock()` 方法中，
呼叫 `setImpl()` 時應該將 `info` 參數（AlarmClockInfo）傳遞到正確位置，
但 bug 將此參數設為 `null`，導致 service 無法得知這是一個 alarm clock，
無法更新系統 UI 和讓其他 app 查詢。

## Bug 位置
`frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (行 806-808)

## 修復方式
```java
// 錯誤的代碼
public void setAlarmClock(AlarmClockInfo info, PendingIntent operation) {
    setImpl(RTC_WAKEUP, info.getTriggerTime(), WINDOW_EXACT, 0, 0,
            operation, null, null, (Handler) null, null, null);  // BUG: 最後參數應該是 info
}

// 正確的代碼
public void setAlarmClock(AlarmClockInfo info, PendingIntent operation) {
    setImpl(RTC_WAKEUP, info.getTriggerTime(), WINDOW_EXACT, 0, 0,
            operation, null, null, (Handler) null, null, info);
}
```

## 相關知識
- AlarmClockInfo 用於系統 UI 顯示鬧鐘圖示
- `getNextAlarmClock()` 依賴此資訊向其他 app 公開下一個鬧鐘
- setAlarmClock 自動使用 RTC_WAKEUP 類型

## 難度說明
**Medium** - 需要理解 AlarmClockInfo 的作用，以及 setImpl 的完整參數列表。
