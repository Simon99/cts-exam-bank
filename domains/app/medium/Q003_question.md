# Q003: Dialog Cancelable 設定不生效

## CTS 測試失敗現象

執行 `android.app.cts.AlertDialogTest#testAlertDialogNotCancelable` 失敗

```
FAILURE: testAlertDialogNotCancelable
java.lang.AssertionError: Dialog was canceled when it should not be

at android.app.cts.AlertDialogTest.testAlertDialogNotCancelable(AlertDialogTest.java:172)
```

## 測試代碼片段

```java
@Test
public void testAlertDialogNotCancelable() {
    startDialogActivity(DialogStubActivity.TEST_ALERTDIALOG_NOT_CANCELABLE);
    assertTrue(mActivity.getDialog().isShowing());
    
    assertFalse(mActivity.onCancelCalled);
    mInstrumentation.sendKeyDownUpSync(KeyEvent.KEYCODE_BACK);
    
    // 按 Back 鍵後，dialog 不應該被取消
    assertFalse(mActivity.onCancelCalled);  // 失敗！onCancelCalled 變成 true
}
```

## 症狀描述

- 創建設定為不可取消的 AlertDialog (`setCancelable(false)`)
- 按下 Back 鍵
- Dialog 仍然被取消了，調用了 onCancel

## 你的任務

1. 分析 Dialog 的 cancelable 機制
2. 找出為什麼 setCancelable(false) 沒有生效
3. 需要追蹤 Back 鍵事件的處理流程
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/Dialog.java`
  - `frameworks/base/core/java/android/app/AlertDialog.java`
- 關注 `setCancelable()` 如何影響 Back 鍵行為
- 關注 `onBackPressed()` 和 `mCancelable` 標誌的使用
- AlertDialog.Builder 的設定是否正確傳遞
