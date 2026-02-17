# Q008: AlertDialog KeyEvent 回調不觸發

## CTS 測試失敗現象

執行 `android.app.cts.AlertDialogTest#testCallback` 失敗

```
FAILURE: testCallback
java.lang.AssertionError: onKeyDown was not called
    at android.app.cts.AlertDialogTest.testCallback(AlertDialogTest.java:160)
```

## 測試代碼片段

```java
@Test
public void testCallback() {
    startDialogActivity(DialogStubActivity.TEST_ALERTDIALOG_CALLBACK);
    assertTrue(mActivity.onCreateCalled);

    mInstrumentation.sendKeySync(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_0));
    assertTrue(mActivity.onKeyDownCalled);  // 失敗！
    
    mInstrumentation.sendKeySync(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_0));
    assertTrue(mActivity.onKeyUpCalled);
}
```

## 症狀描述

- 創建帶有 key event callback 的 AlertDialog
- 發送 KEYCODE_0 按鍵事件
- Dialog 的 onKeyDown 回調沒有被觸發
- Activity 記錄的 onKeyDownCalled 仍為 false

## 你的任務

1. 分析 Dialog 的 key event 處理流程
2. 找出為什麼 onKeyDown 沒有被調用
3. 追蹤 dispatchKeyEvent 的實現
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/Dialog.java`
  - `frameworks/base/core/java/android/view/Window.java`
- 關注 `dispatchKeyEvent()` 或 `onKeyDown()` 方法
- 注意事件是否被正確傳遞給 callback
- Window 層的事件處理也需要檢查
