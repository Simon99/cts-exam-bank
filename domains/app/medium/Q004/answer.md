# Q004: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: DatePickerDialog.java
在 `onClick()` 的 BUTTON_POSITIVE 分支中，檢查了 listener 非空後卻沒有調用它。

### Bug 2: AlertDialog.java
AlertDialog 內部的 ButtonHandler 沒有正確將點擊事件轉發給實現了 OnClickListener 的子類。

## Bug 1 位置

`frameworks/base/core/java/android/app/DatePickerDialog.java`

```java
@Override
public void onClick(DialogInterface dialog, int which) {
    switch (which) {
        case BUTTON_POSITIVE:
            if (mDateSetListener != null) {
                mDatePicker.clearFocus();
                // BUG: 檢查了 listener 但沒有調用！
                // 缺少: mDateSetListener.onDateSet(mDatePicker, ...)
            }
            break;
        case BUTTON_NEGATIVE:
            cancel();
            break;
    }
}
```

## Bug 2 位置

`frameworks/base/core/java/android/app/AlertDialog.java` (ButtonHandler)

```java
private static final class ButtonHandler extends Handler {
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case DialogInterface.BUTTON_POSITIVE:
            case DialogInterface.BUTTON_NEGATIVE:
            case DialogInterface.BUTTON_NEUTRAL:
                // BUG: 只調用了 mListener，沒有檢查 dialog 是否也實現了 OnClickListener
                ((DialogInterface.OnClickListener) msg.obj).onClick(mDialog, msg.what);
                // 缺少: 如果 dialog instanceof OnClickListener，也要調用
                break;
        }
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 DatePickerDialog.onClick 中
Log.d("DatePickerDialog", "onClick which=" + which + ", listener=" + mDateSetListener);

// 在 AlertDialog.ButtonHandler.handleMessage 中  
Log.d("AlertDialog", "ButtonHandler msg.what=" + msg.what);
```

2. **觀察 log**:
```
D AlertDialog: ButtonHandler msg.what=BUTTON_POSITIVE
D DatePickerDialog: onClick which=BUTTON_POSITIVE, listener=OnDateSetListener@xxx
# 沒有 "onDateSet called" 的 log
```

3. **定位問題**: 
   - DatePickerDialog.onClick 被調用但沒有觸發 listener
   - ButtonHandler 可能沒有正確轉發事件

## 問題分析

### Bug 1 分析
DatePickerDialog.onClick() 中 BUTTON_POSITIVE 分支有 null 檢查但沒有實際調用 listener。

### Bug 2 分析
AlertDialog 的 ButtonHandler 在設置了獨立的 OnClickListener 時，可能不會調用 Dialog 自身的 onClick。

## 正確代碼

### 修復 Bug 1 (DatePickerDialog.java)
```java
@Override
public void onClick(DialogInterface dialog, int which) {
    switch (which) {
        case BUTTON_POSITIVE:
            if (mDateSetListener != null) {
                mDatePicker.clearFocus();
                mDateSetListener.onDateSet(mDatePicker, mDatePicker.getYear(),
                        mDatePicker.getMonth(), mDatePicker.getDayOfMonth());
            }
            break;
        case BUTTON_NEGATIVE:
            cancel();
            break;
    }
}
```

### 修復 Bug 2 (AlertDialog.java)
```java
private static final class ButtonHandler extends Handler {
    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case DialogInterface.BUTTON_POSITIVE:
            case DialogInterface.BUTTON_NEGATIVE:
            case DialogInterface.BUTTON_NEUTRAL:
                ((DialogInterface.OnClickListener) msg.obj).onClick(mDialog, msg.what);
                // 添加：如果 dialog 實現了 OnClickListener，也調用它
                if (mDialog instanceof DialogInterface.OnClickListener) {
                    ((DialogInterface.OnClickListener) mDialog).onClick(mDialog, msg.what);
                }
                break;
        }
    }
}
```

## 修復驗證

```bash
atest android.app.cts.DatePickerDialogTest#testOnClick
```

## 難度分類理由

**Medium** - 需要理解 Dialog 的按鈕點擊處理機制，追蹤事件從 ButtonHandler 到 DatePickerDialog 的流程，涉及兩個檔案的協作問題。
