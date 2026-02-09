# Q001: 答案解析

## 問題根源

在 `TimePickerDialog.java` 的 `onSaveInstanceState()` 方法中，保存小時時使用了錯誤的值。

## Bug 位置

`frameworks/base/core/java/android/app/TimePickerDialog.java`

```java
@Override
public Bundle onSaveInstanceState() {
    final Bundle state = super.onSaveInstanceState();
    state.putInt(HOUR, mInitialHourOfDay);  // BUG: 應該是 mTimePicker.getCurrentHour()
    state.putInt(MINUTE, mTimePicker.getCurrentMinute());
    state.putBoolean(IS_24_HOUR, mTimePicker.is24HourView());
    return state;
}
```

## 問題分析

Bug 將 `mTimePicker.getCurrentHour()` 改為 `mInitialHourOfDay`。

- `mInitialHourOfDay` 是構造函數中傳入的初始值，之後不會更新
- 但如果 TimePicker 尚未初始化（在 dialog show 之前），mInitialHourOfDay 可能是 0
- 正確做法是保存 `mTimePicker.getCurrentHour()`，這才是當前選擇的時間

## 正確代碼

```java
@Override
public Bundle onSaveInstanceState() {
    final Bundle state = super.onSaveInstanceState();
    state.putInt(HOUR, mTimePicker.getCurrentHour());
    state.putInt(MINUTE, mTimePicker.getCurrentMinute());
    state.putBoolean(IS_24_HOUR, mTimePicker.is24HourView());
    return state;
}
```

## 修復驗證

修復後重新執行測試：
```bash
atest android.app.cts.TimePickerDialogTest#testSaveInstanceState
```

## 難度分類理由

**Easy** - 讀 CTS fail log 可以直接看到期望值 15 和實際值 0，直接定位到 `onSaveInstanceState()` 方法，單一檔案修復。
