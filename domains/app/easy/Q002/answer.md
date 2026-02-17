# Q002: 答案解析

## 問題根源

在 `ProgressDialog.java` 的 `setMax()` 方法中，當 mProgress 為 null 時，沒有正確保存 max 值。

## Bug 位置

`frameworks/base/core/java/android/app/ProgressDialog.java`

```java
public void setMax(int max) {
    if (mProgress != null) {
        mProgress.setMax(max);
        onProgressChanged();
    } else {
        // BUG: 這裡沒有保存 max 值
        // mMax = max;  <-- 這行被註釋或刪除了
    }
}
```

## 問題分析

ProgressDialog 有兩個階段：
1. **onCreate 之前**：mProgress 為 null，應該用 mMax 臨時保存
2. **onCreate 之後**：mProgress 已初始化，直接設定到 ProgressBar

Bug 移除了 `mMax = max` 這行，導致在 dialog 顯示前調用 setMax() 時值丟失。

## 正確代碼

```java
public void setMax(int max) {
    if (mProgress != null) {
        mProgress.setMax(max);
        onProgressChanged();
    } else {
        mMax = max;  // 正確：保存到臨時變數
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ProgressDialogTest#testAccessMax
```

## 難度分類理由

**Easy** - 錯誤訊息明確指出 getMax() 返回錯誤值，直接查看 setMax/getMax 方法即可定位，單一檔案修復。
