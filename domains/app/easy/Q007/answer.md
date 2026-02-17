# Q007: 答案解析

## 問題根源

在 `TimePickerDialog.java` 的 `updateTime()` 方法中，分鐘沒有被更新。

## Bug 位置

`frameworks/base/core/java/android/app/TimePickerDialog.java`

```java
public void updateTime(int hourOfDay, int minuteOfHour) {
    mTimePicker.setCurrentHour(hourOfDay);
    // BUG: 缺少 mTimePicker.setCurrentMinute(minuteOfHour);
}
```

## 問題分析

`updateTime()` 應該同時更新小時和分鐘，但 Bug 移除了分鐘的更新：
- `setCurrentHour(hourOfDay)` 更新了小時
- `setCurrentMinute(minuteOfHour)` 被移除，分鐘保持原值

## 正確代碼

```java
public void updateTime(int hourOfDay, int minuteOfHour) {
    mTimePicker.setCurrentHour(hourOfDay);
    mTimePicker.setCurrentMinute(minuteOfHour);  // 必須更新分鐘
}
```

## 修復驗證

```bash
atest android.app.cts.TimePickerDialogTest#testUpdateTime
```

## 難度分類理由

**Easy** - 方法名為 updateTime，卻只更新了 hour，邏輯不完整明顯可見，單一檔案一行修復。
