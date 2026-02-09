# Q001: TimePickerDialog 時間保存異常

## CTS 測試失敗現象

執行 `android.app.cts.TimePickerDialogTest#testSaveInstanceState` 失敗

```
FAILURE: testSaveInstanceState
junit.framework.AssertionFailedError: expected:<15> but was:<0>
    at android.app.cts.TimePickerDialogTest.testSaveInstanceState(TimePickerDialogTest.java:78)
```

## 測試代碼片段

```java
@UiThreadTest
@Test
public void testSaveInstanceState() {
    TimePickerDialog tD = new TimePickerDialog(
            mContext, mOnTimeSetListener, TARGET_HOUR, TARGET_MINUTE, true);

    Bundle b = tD.onSaveInstanceState();

    assertEquals(TARGET_HOUR, b.getInt(HOUR));  // 期望 15，實際 0
    assertEquals(TARGET_MINUTE, b.getInt(MINUTE));
    assertTrue(b.getBoolean(IS_24_HOUR));
}
```

## 症狀描述

- 創建 TimePickerDialog 並設定初始時間為 15:09
- 調用 onSaveInstanceState() 保存狀態
- 保存的小時值為 0，而非預期的 15

## 你的任務

1. 找出導致此問題的源碼位置
2. 分析為什麼保存的時間不正確
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/TimePickerDialog.java`
- 關注 `onSaveInstanceState()` 方法的實現
