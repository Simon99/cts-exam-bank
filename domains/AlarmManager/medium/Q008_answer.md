# Q008 Answer: UpdateNextAlarmClock Not Triggered

## 正確答案
**A. `updateNextAlarmClockLocked()` 的比較邏輯使用 `>` 而非 `<`**

## 問題根因
在 `AlarmManagerService.java` 的 `updateNextAlarmClockLocked()` 方法中，
判斷新鬧鐘是否比當前 next alarm clock 更早時，
應該使用 `newTime < currentNextTime`，
但 bug 將條件寫成 `newTime > currentNextTime`，
導致只有更晚的鬧鐘才會觸發更新，完全相反。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
private void updateNextAlarmClockLocked() {
    AlarmClockInfo newNext = findNextAlarmClockForUser();
    if (mNextAlarmClockForUser == null ||
            (newNext != null && newNext.getTriggerTime() > mNextAlarmClockForUser.getTriggerTime())) {
        // BUG: > 應該是 <
        mNextAlarmClockForUser = newNext;
        sendNextAlarmClockChanged();
    }
}

// 正確的代碼
private void updateNextAlarmClockLocked() {
    AlarmClockInfo newNext = findNextAlarmClockForUser();
    if (mNextAlarmClockForUser == null ||
            (newNext != null && newNext.getTriggerTime() < mNextAlarmClockForUser.getTriggerTime())) {
        mNextAlarmClockForUser = newNext;
        sendNextAlarmClockChanged();
    }
}
```

## 相關知識
- `ACTION_NEXT_ALARM_CLOCK_CHANGED` 讓 launcher、widget 知道鬧鐘變更
- 只有 alarm clock（非一般 alarm）會觸發此廣播
- 狀態列鬧鐘圖示也依賴此機制

## 難度說明
**Medium** - 需要理解 next alarm clock 更新的觸發邏輯。
