# Q006: AlertDialog 按鈕文字獲取錯誤

## CTS 測試失敗現象

執行 `android.app.cts.AlertDialogTest#testAlertDialog` 失敗

```
FAILURE: testAlertDialog
junit.framework.AssertionFailedError: expected:<OK> but was:<Cancel>
    at android.app.cts.AlertDialogTest.testAlertDialog(AlertDialogTest.java:82)

Error comparing positive button text
```

## 測試代碼片段

```java
@Test
public void testAlertDialog() throws Throwable {
    startDialogActivity(DialogStubActivity.TEST_ALERTDIALOG);
    assertTrue(mActivity.getDialog().isShowing());

    mPositiveButton = ((AlertDialog) (mActivity.getDialog())).getButton(
            DialogInterface.BUTTON_POSITIVE);
    assertNotNull(mPositiveButton);
    assertEquals(mActivity.getString(R.string.alert_dialog_positive),
            mPositiveButton.getText());  // 期望 "OK"，實際 "Cancel"
}
```

## 症狀描述

- 創建 AlertDialog 並設定三個按鈕（Positive、Negative、Neutral）
- 調用 getButton(BUTTON_POSITIVE) 獲取正向按鈕
- 返回的按鈕文字是 "Cancel" 而非 "OK"

## 你的任務

1. 找出導致按鈕獲取錯誤的原因
2. 分析 getButton() 的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/AlertDialog.java`
- 關注 `getButton()` 方法和按鈕常量的映射
