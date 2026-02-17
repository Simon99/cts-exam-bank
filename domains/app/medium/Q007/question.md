# Q007: ProgressDialog 水平樣式進度不更新

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testSetProgressStyle` 失敗

```
FAILURE: testSetProgressStyle
java.lang.AssertionError: Progress not updated in horizontal style
    Expected progress: 10
    Actual progress: 0
```

## 測試代碼片段

```java
@UiThreadTest
public void testSetProgressStyle() throws Throwable {
    ProgressDialog dialog = new ProgressDialog(mContext);
    setProgressStyle(dialog, ProgressDialog.STYLE_HORIZONTAL);
}

private void setProgressStyle(ProgressDialog dialog, int style) {
    dialog.setProgressStyle(style);
    dialog.show();
    dialog.setProgress(10);
    dialog.setMax(100);
    
    assertEquals(10, dialog.getProgress());  // 失敗！返回 0
    assertEquals(100, dialog.getMax());
}
```

## 症狀描述

- 設定 ProgressDialog 為水平樣式 (STYLE_HORIZONTAL)
- 顯示 Dialog 後設定進度為 10
- getProgress() 返回 0，進度沒有更新

## 你的任務

1. 分析 STYLE_HORIZONTAL 模式下的進度更新機制
2. 找出為什麼進度沒有正確設定
3. 對比 show() 前後設定進度的差異
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/ProgressDialog.java`
  - `frameworks/base/core/java/android/app/AlertDialog.java`
- 關注 `onCreate()` 和 `setProgress()` 方法
- 注意 mProgress (ProgressBar) 的初始化時機
- 關注 `mHasStarted` 標誌的作用
