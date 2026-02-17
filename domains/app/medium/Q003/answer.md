# Q003: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: Dialog.java
在 `onBackPressed()` 方法中，忽略了 `mCancelable` 標誌，直接調用 cancel()。

### Bug 2: AlertDialog.java
AlertDialog.Builder 的 `setCancelable()` 沒有正確傳遞給父類 Dialog。

## Bug 1 位置

`frameworks/base/core/java/android/app/Dialog.java`

```java
public void onBackPressed() {
    // BUG: 忽略 mCancelable 標誌
    cancel();
    // 應該是: if (mCancelable) { cancel(); }
}
```

## Bug 2 位置

`frameworks/base/core/java/android/app/AlertDialog.java` (Builder 內部)

```java
public static class Builder {
    // ...
    
    public Builder setCancelable(boolean cancelable) {
        // BUG: 只設置了 Builder 的狀態，沒有在 create() 時傳遞給 Dialog
        P.mCancelable = cancelable;
        return this;
    }
    
    public AlertDialog create() {
        final AlertDialog dialog = new AlertDialog(P.mContext, mTheme);
        // BUG: 缺少 dialog.setCancelable(P.mCancelable);
        P.apply(dialog.mAlert);
        // ...
        return dialog;
    }
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 Dialog.onBackPressed 中
Log.d("Dialog", "onBackPressed, mCancelable=" + mCancelable);

// 在 Dialog.setCancelable 中  
Log.d("Dialog", "setCancelable called with: " + flag);

// 在 AlertDialog.Builder.create 中
Log.d("AlertDialog", "create: P.mCancelable=" + P.mCancelable);
```

2. **觀察 log**:
```
D AlertDialog: create: P.mCancelable=false
D Dialog: onBackPressed, mCancelable=true  // 沒有被設定！
```

3. **定位問題**: 
   - Builder 的 cancelable 設定沒有傳遞給 Dialog
   - onBackPressed 沒有檢查 mCancelable

## 問題分析

### Bug 1 分析
Dialog.java 的 `onBackPressed()` 直接調用 `cancel()` 而沒有檢查 `mCancelable` 標誌。

### Bug 2 分析
AlertDialog.Builder 在 `create()` 時沒有調用 `dialog.setCancelable(P.mCancelable)`，導致 Builder 的設定丟失。

## 正確代碼

### 修復 Bug 1 (Dialog.java)
```java
public void onBackPressed() {
    if (mCancelable) {
        cancel();
    }
}
```

### 修復 Bug 2 (AlertDialog.java)
```java
public AlertDialog create() {
    final AlertDialog dialog = new AlertDialog(P.mContext, mTheme);
    P.apply(dialog.mAlert);
    dialog.setCancelable(P.mCancelable);  // 添加這行
    // ...
    return dialog;
}
```

## 修復驗證

```bash
atest android.app.cts.AlertDialogTest#testAlertDialogNotCancelable
```

## 難度分類理由

**Medium** - 需要理解 Dialog 的取消機制以及 Builder 模式中屬性如何傳遞，涉及兩個檔案的協作問題。
