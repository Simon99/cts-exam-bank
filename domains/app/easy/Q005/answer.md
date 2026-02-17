# Q005: 答案解析

## 問題根源

在 `DatePickerDialog.java` 的 `onSaveInstanceState()` 方法中，保存月份時使用了錯誤的 getter 方法。

## Bug 位置

`frameworks/base/core/java/android/app/DatePickerDialog.java`

```java
@Override
public Bundle onSaveInstanceState() {
    final Bundle state = super.onSaveInstanceState();
    state.putInt(YEAR, mDatePicker.getYear());
    state.putInt(MONTH, mDatePicker.getDayOfMonth());  // BUG: 應該是 getMonth()
    state.putInt(DAY, mDatePicker.getDayOfMonth());
    return state;
}
```

## 問題分析

Bug 將 `getMonth()` 錯誤地改為 `getDayOfMonth()`：
- MONTH key 應該存月份 (0-11)
- 但卻存了日期 (1-31)
- 當日期是 25 號時，測試可能看到 25 而非 11
- 當日期是 1 號時，測試看到 0（因為還有其他測試環境問題）

## 正確代碼

```java
@Override
public Bundle onSaveInstanceState() {
    final Bundle state = super.onSaveInstanceState();
    state.putInt(YEAR, mDatePicker.getYear());
    state.putInt(MONTH, mDatePicker.getMonth());      // 正確
    state.putInt(DAY, mDatePicker.getDayOfMonth());
    return state;
}
```

## 修復驗證

```bash
atest android.app.cts.DatePickerDialogTest#testOnSaveInstanceState
```

## 難度分類理由

**Easy** - 測試名稱和錯誤訊息明確指向 state save，方法調用錯誤一目了然，單一檔案修復。
