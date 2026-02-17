# Q010: ProgressDialog 二級進度增量錯誤

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testIncrementSecondaryProgressBy` 失敗

```
FAILURE: testIncrementSecondaryProgressBy
junit.framework.AssertionFailedError: expected:<70> but was:<10>
    at android.app.cts.ProgressDialogTest.testIncrementSecondaryProgressBy(ProgressDialogTest.java:232)
```

## 測試代碼片段

```java
@UiThreadTest
public void testIncrementSecondaryProgressBy() throws Throwable {
    ProgressDialog dialog = new ProgressDialog(mContext);
    dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
    dialog.show();
    
    dialog.setSecondaryProgress(10);
    mProgress1 = dialog.getSecondaryProgress();     // 預期 10
    dialog.incrementSecondaryProgressBy(60);
    mProgress2 = dialog.getSecondaryProgress();     // 預期 70，實際 10

    assertEquals(10, mProgress1);
    assertEquals(70, mProgress2);                    // 失敗！
}
```

## 症狀描述

- 設定二級進度為 10
- 調用 incrementSecondaryProgressBy(60) 增加 60
- 二級進度仍為 10，沒有增加

## 你的任務

1. 找出導致二級進度增量不生效的原因
2. 分析 incrementSecondaryProgressBy() 的實現
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/ProgressDialog.java`
- 關注 `incrementSecondaryProgressBy()` 方法
- 對比 `incrementProgressBy()` 的實現
