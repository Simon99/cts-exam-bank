# Q005: DatePickerDialog 日期保存錯誤

## CTS 測試失敗現象

執行 `android.app.cts.DatePickerDialogTest#testOnSaveInstanceState` 失敗

```
FAILURE: testOnSaveInstanceState
junit.framework.AssertionFailedError: expected:<11> but was:<0>
    at android.app.cts.DatePickerDialogTest.testOnSaveInstanceState(DatePickerDialogTest.java:89)

Test was checking month value in saved bundle
```

## 測試代碼片段

```java
@UiThreadTest
@Test
public void testOnSaveInstanceState() {
    DatePickerDialog dialog = new DatePickerDialog(mContext, null, 2024, 11, 25);
    
    Bundle state = dialog.onSaveInstanceState();
    
    assertEquals(2024, state.getInt("year"));
    assertEquals(11, state.getInt("month"));   // 期望 11，實際 0
    assertEquals(25, state.getInt("day"));
}
```

## 症狀描述

- 創建 DatePickerDialog 設定日期為 2024 年 12 月 25 日（month=11，0-indexed）
- 保存狀態時，月份值為 0 而非 11

## 你的任務

1. 找出導致月份保存錯誤的原因
2. 分析 onSaveInstanceState() 的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/DatePickerDialog.java`
- 關注 `onSaveInstanceState()` 方法
- 注意 Bundle key 的使用
