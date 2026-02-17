# Q009: 答案解析

## 問題根源

在 `TimePickerDialog.java` 的 `onRestoreInstanceState()` 方法中，分鐘恢復缺失。

## Bug 位置

`frameworks/base/core/java/android/app/TimePickerDialog.java`

```java
@Override
public void onRestoreInstanceState(Bundle savedInstanceState) {
    super.onRestoreInstanceState(savedInstanceState);
    final int hour = savedInstanceState.getInt(HOUR);
    final int minute = savedInstanceState.getInt(MINUTE);
    mTimePicker.setIs24HourView(savedInstanceState.getBoolean(IS_24_HOUR));
    mTimePicker.setCurrentHour(hour);
    // BUG: 缺少 mTimePicker.setCurrentMinute(minute);
}
```

## 問題分析

Bug 移除了設置分鐘的代碼行：
- 從 Bundle 讀取了 minute 值
- 設置了 is24HourView 和 hour
- 但沒有設置 minute 到 TimePicker

這導致恢復後分鐘保持構造時的初始值。

## 正確代碼

```java
@Override
public void onRestoreInstanceState(Bundle savedInstanceState) {
    super.onRestoreInstanceState(savedInstanceState);
    final int hour = savedInstanceState.getInt(HOUR);
    final int minute = savedInstanceState.getInt(MINUTE);
    mTimePicker.setIs24HourView(savedInstanceState.getBoolean(IS_24_HOUR));
    mTimePicker.setCurrentHour(hour);
    mTimePicker.setCurrentMinute(minute);  // 必須恢復分鐘
}
```

## 修復驗證

```bash
atest android.app.cts.TimePickerDialogTest#testOnRestoreInstanceState
```

## 難度分類理由

**Easy** - 錯誤訊息指明分鐘沒有恢復，onRestoreInstanceState 方法中缺少一行 setCurrentMinute 調用明顯可見，單一檔案修復。
