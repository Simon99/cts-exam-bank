# Q006: 答案解析

## 問題根源

在 `AlertDialog.java` 的 `getButton()` 方法中，按鈕常量映射錯誤。

## Bug 位置

`frameworks/base/core/java/android/app/AlertDialog.java`

```java
public Button getButton(int whichButton) {
    switch (whichButton) {
        case BUTTON_POSITIVE:
            return mAlert.getButton(BUTTON_NEGATIVE);  // BUG: 應該是 BUTTON_POSITIVE
        case BUTTON_NEGATIVE:
            return mAlert.getButton(BUTTON_POSITIVE);  // BUG: 應該是 BUTTON_NEGATIVE
        case BUTTON_NEUTRAL:
            return mAlert.getButton(BUTTON_NEUTRAL);
        default:
            return null;
    }
}
```

## 問題分析

Bug 交換了 BUTTON_POSITIVE 和 BUTTON_NEGATIVE 的映射：
- 請求 BUTTON_POSITIVE 時，返回了 BUTTON_NEGATIVE
- 請求 BUTTON_NEGATIVE 時，返回了 BUTTON_POSITIVE
- 導致正向和負向按鈕混淆

## 正確代碼

```java
public Button getButton(int whichButton) {
    switch (whichButton) {
        case BUTTON_POSITIVE:
            return mAlert.getButton(BUTTON_POSITIVE);
        case BUTTON_NEGATIVE:
            return mAlert.getButton(BUTTON_NEGATIVE);
        case BUTTON_NEUTRAL:
            return mAlert.getButton(BUTTON_NEUTRAL);
        default:
            return null;
    }
}
```

## 修復驗證

```bash
atest android.app.cts.AlertDialogTest#testAlertDialog
```

## 難度分類理由

**Easy** - 錯誤訊息指出按鈕文字錯誤，getButton 方法邏輯簡單，常量映射問題明顯，單一檔案修復。
