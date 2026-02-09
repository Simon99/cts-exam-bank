# Q002: ProgressDialog 進度最大值錯誤

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testAccessMax` 失敗

```
FAILURE: testAccessMax
junit.framework.AssertionFailedError: expected:<2008> but was:<100>
    at android.app.cts.ProgressDialogTest.testAccessMax(ProgressDialogTest.java:112)
```

## 測試代碼片段

```java
@UiThreadTest
public void testAccessMax() {
    // progressDialog is null
    ProgressDialog progressDialog = buildDialog();
    progressDialog.setMax(2008);
    assertEquals(2008, progressDialog.getMax());  // 期望 2008，實際 100
}
```

## 症狀描述

- 創建新的 ProgressDialog
- 設定最大值為 2008
- 調用 getMax() 返回 100（預設值），而非設定的 2008

## 你的任務

1. 找出導致此問題的源碼位置
2. 分析為什麼 setMax() 沒有正確保存值
3. 提出修復方案

## 提示

- 相關源碼：`frameworks/base/core/java/android/app/ProgressDialog.java`
- 關注 `setMax()` 和 `getMax()` 方法的實現
- 注意 dialog 顯示前後的狀態差異
