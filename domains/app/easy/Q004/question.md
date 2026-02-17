# Q004: ProgressDialog 進度增量計算錯誤

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testIncrementProgressBy` 失敗

```
FAILURE: testIncrementProgressBy
junit.framework.AssertionFailedError: expected:<70> but was:<60>
    at android.app.cts.ProgressDialogTest.testIncrementProgressBy(ProgressDialogTest.java:218)
```

## 測試代碼片段

```java
@UiThreadTest
public void testIncrementProgressBy() throws Throwable {
    ProgressDialog dialog = new ProgressDialog(mContext);
    dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
    dialog.show();
    
    dialog.setProgress(10);
    mProgress1 = dialog.getProgress();      // 預期 10
    dialog.incrementProgressBy(60);
    mProgress2 = dialog.getProgress();      // 預期 70，實際 60
    dialog.cancel();

    assertEquals(10, mProgress1);
    assertEquals(70, mProgress2);           // 失敗！
}
```

## 症狀描述

- 設定初始進度為 10
- 調用 incrementProgressBy(60) 增加 60
- 結果進度為 60，而非預期的 70 (10 + 60)

## 你的任務

1. 找出導致增量計算錯誤的原因
2. 分析 incrementProgressBy() 的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/ProgressDialog.java`
- 關注 `incrementProgressBy()` 方法
- 對比 ProgressBar 的 incrementProgressBy 行為
