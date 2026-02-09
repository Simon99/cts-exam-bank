# Q008: 答案解析

## 問題根源

在 `ProgressDialog.java` 的 `setIndeterminate()` 方法中，當 mProgress 為 null 時的邏輯錯誤。

## Bug 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
public void setIndeterminate(boolean indeterminate) {
    if (mProgress != null) {
        mProgress.setIndeterminate(indeterminate);
    } else {
        mIndeterminate = true;  // BUG: 應該是 mIndeterminate = indeterminate
    }
}
```

## 問題分析

Bug 把條件賦值改成了固定賦值：
- 原本：`mIndeterminate = indeterminate`（保存傳入的值）
- Bug：`mIndeterminate = true`（永遠設為 true）

這導致即使調用 `setIndeterminate(false)`，mIndeterminate 仍然是 true。

## 正確代碼

```java
public void setIndeterminate(boolean indeterminate) {
    if (mProgress != null) {
        mProgress.setIndeterminate(indeterminate);
    } else {
        mIndeterminate = indeterminate;  // 正確：保存實際值
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testSetIndeterminate
```

## 難度分類理由

**Easy** - 測試清楚指出 boolean 狀態錯誤，setIndeterminate 方法邏輯簡單，問題一目了然，單一檔案修復。
