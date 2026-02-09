# Q008: ProgressDialog setIndeterminate 狀態錯誤

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testSetIndeterminate` 失敗

```
FAILURE: testSetIndeterminate
junit.framework.AssertionFailedError: expected false but was true
    at android.app.cts.ProgressDialogTest.testSetIndeterminate(ProgressDialogTest.java:195)
```

## 測試代碼片段

```java
@UiThreadTest
public void testSetIndeterminate() {
    // progress is null
    ProgressDialog dialog = buildDialog();
    dialog.setIndeterminate(true);
    assertTrue(dialog.isIndeterminate());
    dialog.setIndeterminate(false);
    assertFalse(dialog.isIndeterminate());  // 期望 false，實際 true
}
```

## 症狀描述

- 創建 ProgressDialog（未顯示，mProgress 為 null）
- 設定 indeterminate 為 true，驗證正確
- 設定 indeterminate 為 false
- isIndeterminate() 仍返回 true

## 你的任務

1. 找出導致 indeterminate 狀態不更新的原因
2. 分析 setIndeterminate() 在 mProgress 為 null 時的行為
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/ProgressDialog.java`
- 關注 `setIndeterminate()` 和 `isIndeterminate()` 方法
- 注意 mIndeterminate 成員變數的使用
