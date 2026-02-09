# Q007: TimePickerDialog 時間更新失敗

## CTS 測試失敗現象

執行 `android.app.cts.TimePickerDialogTest#testUpdateTime` 失敗

```
FAILURE: testUpdateTime
junit.framework.AssertionFailedError: expected:<18> but was:<9>
    at android.app.cts.TimePickerDialogTest.testUpdateTime(TimePickerDialogTest.java:112)

Minute value not updated correctly
```

## 測試代碼片段

```java
@UiThreadTest
@Test
public void testUpdateTime() {
    TimePickerDialog timePickerDialog = buildDialog();  // 初始 15:09
    int minute = 18;
    timePickerDialog.updateTime(TARGET_HOUR, minute);

    // 通過 onSaveInstanceState 檢查實際值
    Bundle b = timePickerDialog.onSaveInstanceState();

    assertEquals(TARGET_HOUR, b.getInt(HOUR));
    assertEquals(minute, b.getInt(MINUTE));  // 期望 18，實際 9
}
```

## 症狀描述

- 創建 TimePickerDialog，初始時間 15:09
- 調用 updateTime(15, 18) 更新分鐘為 18
- 保存狀態後，分鐘仍為 9

## 你的任務

1. 找出導致時間更新失敗的原因
2. 分析 updateTime() 方法的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/TimePickerDialog.java`
- 關注 `updateTime()` 方法
- 注意 TimePicker 的 setCurrentMinute 調用
