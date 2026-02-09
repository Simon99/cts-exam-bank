# Q007: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: ProgressDialog.java
在 `setProgress()` 中，當 Dialog 尚未 start 時沒有保存進度值，導致值丟失。

### Bug 2: AlertDialog.java
AlertDialog 的 `show()` 方法在某些情況下沒有正確觸發 `onCreate()`，導致 mHasStarted 沒有被設置。

## Bug 1 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
public void setProgress(int value) {
    if (mHasStarted) {
        mProgress.setProgress(value);
        onProgressChanged();
    } else {
        // BUG: 缺少保存值的邏輯
        // 應該是: mProgressVal = value;
    }
}
```

## Bug 2 位置

`frameworks/base/core/java/android/app/AlertDialog.java`

```java
@Override
public void show() {
    // BUG: 某些路徑沒有調用 super.show()，導致 onCreate 沒被調用
    if (mShowing) {
        return;  // 提前返回，但狀態可能不一致
    }
    // 缺少: super.show() 或 create() 調用
    mShowing = true;
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 ProgressDialog.setProgress 中
Log.d("ProgressDialog", "setProgress: mHasStarted=" + mHasStarted + ", value=" + value);

// 在 ProgressDialog.onCreate 中
Log.d("ProgressDialog", "onCreate called");

// 在 ProgressDialog.onStart 中
Log.d("ProgressDialog", "onStart called, setting mHasStarted=true");
```

2. **觀察 log**:
```
D ProgressDialog: setProgress: mHasStarted=false, value=10
# 沒有 mProgressVal = value 的處理
D ProgressDialog: onCreate called
D ProgressDialog: onStart called, setting mHasStarted=true
# 此時 value 已經丟失
```

3. **定位問題**: setProgress 在 mHasStarted=false 時沒有保存值

## 問題分析

### Bug 1 分析
setProgress() 的 else 分支應該將值保存到 mProgressVal，這樣 onStart() 時可以恢復。

### Bug 2 分析
AlertDialog 的 show() 流程可能跳過 onCreate()，導致子類的初始化邏輯不被執行。

## 正確代碼

### 修復 Bug 1 (ProgressDialog.java)
```java
public void setProgress(int value) {
    if (mHasStarted) {
        mProgress.setProgress(value);
        onProgressChanged();
    } else {
        mProgressVal = value;  // 保存值供 onStart 使用
    }
}
```

### 修復 Bug 2 (AlertDialog.java)
```java
@Override
public void show() {
    if (!mCreated) {
        create();
    }
    super.show();
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testSetProgressStyle
```

## 難度分類理由

**Medium** - 需要理解 Dialog 的生命周期和延遲初始化機制，追蹤 mHasStarted 標誌在不同階段的影響，涉及兩個檔案的協作問題。
