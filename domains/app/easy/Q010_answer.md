# Q010: 答案解析

## 問題根源

在 `ProgressDialog.java` 的 `incrementSecondaryProgressBy()` 方法中，錯誤地調用了主進度的增量方法。

## Bug 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
public void incrementSecondaryProgressBy(int diff) {
    if (mProgress != null) {
        mProgress.incrementProgressBy(diff);  // BUG: 應該是 incrementSecondaryProgressBy
        onProgressChanged();
    } else {
        mIncrementSecondaryBy += diff;
    }
}
```

## 問題分析

Bug 把 `incrementSecondaryProgressBy` 改成了 `incrementProgressBy`：
- 這導致增加的是主進度而非二級進度
- 二級進度保持不變
- 主進度被意外增加

## 正確代碼

```java
public void incrementSecondaryProgressBy(int diff) {
    if (mProgress != null) {
        mProgress.incrementSecondaryProgressBy(diff);  // 正確：增加二級進度
        onProgressChanged();
    } else {
        mIncrementSecondaryBy += diff;
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testIncrementSecondaryProgressBy
```

## 難度分類理由

**Easy** - 方法名和測試名明確指向 secondary progress，錯誤調用了 incrementProgressBy 而非 incrementSecondaryProgressBy，單一檔案修復。
