# Q010: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: ProgressDialog.java
在 `mViewUpdateHandler` 的消息處理中，計算了百分比但沒有設置到 TextView。

### Bug 2: Handler.java
Handler 的 `dispatchMessage()` 在某些情況下沒有正確執行 callback，導致消息丟失。

## Bug 1 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
private Handler mViewUpdateHandler = new Handler() {
    @Override
    public void handleMessage(Message msg) {
        super.handleMessage(msg);
        
        int progress = mProgress.getProgress();
        int max = mProgress.getMax();
        if (mProgressNumberFormat != null) {
            // ...
        }
        if (mProgressPercentFormat != null) {
            double percent = (double) progress / (double) max;
            SpannableString tmp = new SpannableString(mProgressPercentFormat.format(percent));
            tmp.setSpan(new StyleSpan(android.graphics.Typeface.BOLD),
                    0, tmp.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            // BUG: 缺少 mProgressPercent.setText(tmp);
        } else {
            mProgressPercent.setText("");
        }
    }
};
```

## Bug 2 位置

`frameworks/base/core/java/android/os/Handler.java`

```java
public void dispatchMessage(@NonNull Message msg) {
    if (msg.callback != null) {
        handleCallback(msg);
    } else {
        if (mCallback != null) {
            // BUG: 即使 mCallback.handleMessage 返回 true，也繼續執行
            mCallback.handleMessage(msg);
        }
        // BUG: 某些情況下 handleMessage 不被調用
        // handleMessage(msg);  // 可能被跳過
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 ProgressDialog.mViewUpdateHandler.handleMessage 中
Log.d("ProgressDialog", "handleMessage: progress=" + progress + ", max=" + max);
Log.d("ProgressDialog", "percent format=" + mProgressPercentFormat);

// 在 Handler.dispatchMessage 中
Log.d("Handler", "dispatchMessage: msg.what=" + msg.what);
```

2. **觀察 log**:
```
D ProgressDialog: handleMessage: progress=50, max=100
D ProgressDialog: percent format=NumberFormat@xxx
D ProgressDialog: formatted="50%"
# 但沒有 setText 的 log
```

3. **定位問題**: 計算了百分比但沒有 setText

## 問題分析

### Bug 1 分析
mViewUpdateHandler 的 handleMessage 中，在 mProgressPercentFormat != null 的分支計算了百分比字符串，但沒有調用 mProgressPercent.setText(tmp) 來更新 UI。

### Bug 2 分析
Handler.dispatchMessage 的某些路徑可能導致 handleMessage 不被調用，影響 UI 更新。

## 正確代碼

### 修復 Bug 1 (ProgressDialog.java)
```java
if (mProgressPercentFormat != null) {
    double percent = (double) progress / (double) max;
    SpannableString tmp = new SpannableString(mProgressPercentFormat.format(percent));
    tmp.setSpan(new StyleSpan(android.graphics.Typeface.BOLD),
            0, tmp.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
    mProgressPercent.setText(tmp);  // 添加這行
} else {
    mProgressPercent.setText("");
}
```

### 修復 Bug 2 (Handler.java)
```java
public void dispatchMessage(@NonNull Message msg) {
    if (msg.callback != null) {
        handleCallback(msg);
    } else {
        if (mCallback != null) {
            if (mCallback.handleMessage(msg)) {
                return;
            }
        }
        handleMessage(msg);  // 確保總是調用
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testSetProgressPercentFormat
```

## 難度分類理由

**Medium** - 需要理解 Handler 消息處理機制和 ProgressDialog 的 UI 更新流程，追蹤消息從發送到處理的完整路徑，涉及兩個檔案的協作問題。
