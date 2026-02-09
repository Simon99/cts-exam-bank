# Q010: ProgressDialog 百分比格式不顯示

## CTS 測試失敗現象

執行 `android.app.cts.ProgressDialogTest#testSetProgressPercentFormat` 失敗

```
FAILURE: testSetProgressPercentFormat
java.lang.AssertionError: Percentage text not updated
    Expected: progress_percent TextView to show "50%"
    Actual: shows empty string ""
```

## 測試代碼片段

```java
@UiThreadTest
public void testSetProgressPercentFormat() throws Throwable {
    ProgressDialog dialog = new ProgressDialog(mContext);
    dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
    dialog.show();
    
    dialog.setMax(100);
    dialog.setProgress(50);
    
    // 驗證百分比顯示
    Window w = dialog.getWindow();
    TextView percentView = (TextView) w.findViewById(android.R.id.progress_percent);
    
    // 期望顯示 "50%"，實際為空
    assertFalse(TextUtils.isEmpty(percentView.getText()));
}
```

## 症狀描述

- 創建水平樣式的 ProgressDialog
- 設定進度為 50/100
- progress_percent TextView 應該顯示 "50%"
- 實際顯示為空字符串

## 你的任務

1. 分析 ProgressDialog 百分比更新機制
2. 找出為什麼百分比文字沒有更新
3. 追蹤 onProgressChanged 的處理流程
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/ProgressDialog.java`
  - `frameworks/base/core/java/android/os/Handler.java`
- 關注 `onProgressChanged()` 方法
- 關注 `mViewUpdateHandler` 的消息處理
- Handler 消息可能被跳過或延遲
