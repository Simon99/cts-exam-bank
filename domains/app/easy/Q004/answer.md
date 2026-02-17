# Q004: 答案解析

## 問題根源

在 `ProgressDialog.java` 的 `incrementProgressBy()` 方法中，錯誤地調用了 `setProgress()` 而非 `incrementProgressBy()`。

## Bug 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
public void incrementProgressBy(int diff) {
    if (mProgress != null) {
        mProgress.setProgress(diff);  // BUG: 應該是 incrementProgressBy(diff)
        onProgressChanged();
    } else {
        mIncrementBy += diff;
    }
}
```

## 問題分析

- `setProgress(diff)` 是設定絕對值
- `incrementProgressBy(diff)` 才是增量操作
- Bug 把 `incrementProgressBy` 改成了 `setProgress`，導致：
  - 原本進度 10，增加 60 後應該是 70
  - 實際變成設定為 60

## 正確代碼

```java
public void incrementProgressBy(int diff) {
    if (mProgress != null) {
        mProgress.incrementProgressBy(diff);  // 正確：增量操作
        onProgressChanged();
    } else {
        mIncrementBy += diff;
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testIncrementProgressBy
```

## 難度分類理由

**Easy** - 錯誤值 60 vs 預期 70 明確指出增量計算問題，方法名已經暗示了問題所在，單一檔案修復。
