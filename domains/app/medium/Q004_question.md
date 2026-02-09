# Q004: DatePickerDialog onClick 回調不觸發

## CTS 測試失敗現象

執行 `android.app.cts.DatePickerDialogTest#testOnClick` 失敗

```
FAILURE: testOnClick
java.lang.AssertionError: OnDateSetListener was not called
    Expected mCallbackYear to be: 2024
    Actual mCallbackYear: 0 (initial value, never set)
```

## 測試代碼片段

```java
@Test
public void testOnClick() {
    mCallbackYear = 0;
    
    DatePickerDialog dialog = new DatePickerDialog(mContext, 
        new OnDateSetListener() {
            public void onDateSet(DatePicker view, int year, int month, int day) {
                mCallbackYear = year;
                mCallbackMonth = month;
                mCallbackDay = day;
            }
        }, 2024, 5, 15);
    
    dialog.show();
    
    // 模擬點擊 OK 按鈕
    dialog.onClick(dialog, DialogInterface.BUTTON_POSITIVE);
    
    assertEquals(2024, mCallbackYear);  // 失敗！mCallbackYear 仍為 0
}
```

## 症狀描述

- 創建 DatePickerDialog 並設定 OnDateSetListener
- 點擊 BUTTON_POSITIVE (OK 按鈕)
- OnDateSetListener.onDateSet() 沒有被調用
- 回調中的年/月/日值沒有被設定

## 你的任務

1. 分析 DatePickerDialog.onClick() 的實現
2. 找出為什麼 listener 沒有被調用
3. 追蹤 BUTTON_POSITIVE 的處理流程
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/DatePickerDialog.java`
  - `frameworks/base/core/java/android/app/AlertDialog.java`
- 關注 `onClick(DialogInterface, int)` 方法
- 對比 TimePickerDialog 的實現
- 關注父類 AlertDialog 的按鈕點擊處理
