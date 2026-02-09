# Q009: TimePickerDialog 時間恢復錯誤

## CTS 測試失敗現象

執行 `android.app.cts.TimePickerDialogTest#testOnRestoreInstanceState` 失敗

```
FAILURE: testOnRestoreInstanceState
junit.framework.AssertionFailedError: expected:<27> but was:<9>
    at android.app.cts.TimePickerDialogTest.testOnRestoreInstanceState(TimePickerDialogTest.java:125)

Minute was not restored correctly
```

## 測試代碼片段

```java
@UiThreadTest
@Test
public void testOnRestoreInstanceState() {
    int minute = 27;
    Bundle b1 = new Bundle();
    b1.putInt(HOUR, TARGET_HOUR);
    b1.putInt(MINUTE, minute);
    b1.putBoolean(IS_24_HOUR, false);

    TimePickerDialog timePickerDialog = buildDialog();  // 初始 15:09
    timePickerDialog.onRestoreInstanceState(b1);

    // 驗證恢復的值
    Bundle b2 = timePickerDialog.onSaveInstanceState();

    assertEquals(TARGET_HOUR, b2.getInt(HOUR));
    assertEquals(minute, b2.getInt(MINUTE));  // 期望 27，實際 9
    assertFalse(b2.getBoolean(IS_24_HOUR));
}
```

## 症狀描述

- 創建包含時間狀態的 Bundle（分鐘=27）
- 調用 onRestoreInstanceState 恢復狀態
- 保存狀態後，分鐘仍為初始值 9，而非恢復的 27

## 你的任務

1. 找出導致分鐘沒有恢復的原因
2. 分析 onRestoreInstanceState() 的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/TimePickerDialog.java`
- 關注 `onRestoreInstanceState()` 方法
- 對比 onSaveInstanceState 的 key 名稱
