# Q008: 答案解析

## 問題根源

本題有兩個 Bug，分別在不同檔案：

### Bug 1: Dialog.java
在 `dispatchKeyEvent()` 中，當 Window 沒有消費事件時直接返回 false，沒有讓事件繼續分發到 onKeyDown/onKeyUp。

### Bug 2: Window.java
Window 的 `superDispatchKeyEvent()` 錯誤地消費了本應傳遞給 Dialog callback 的事件。

## Bug 1 位置

`frameworks/base/core/java/android/app/Dialog.java`

```java
@Override
public boolean dispatchKeyEvent(@NonNull KeyEvent event) {
    if ((mOnKeyListener != null) && (mOnKeyListener.onKey(this, event.getKeyCode(), event))) {
        return true;
    }
    if (mWindow.superDispatchKeyEvent(event)) {
        return true;
    }
    // BUG: 直接返回 false，沒有調用 event.dispatch()
    return false;
    // 應該是: return event.dispatch(this, mDecor != null 
    //             ? mDecor.getKeyDispatcherState() : null, this);
}
```

## Bug 2 位置

`frameworks/base/core/java/android/view/Window.java` (PhoneWindow)

```java
@Override
public boolean superDispatchKeyEvent(KeyEvent event) {
    // BUG: 錯誤地總是返回 true，消費了所有事件
    mDecor.superDispatchKeyEvent(event);
    return true;
    // 應該是: return mDecor.superDispatchKeyEvent(event);
}
```

## 診斷步驟

1. **加入 log 追蹤**:
```java
// 在 Dialog.dispatchKeyEvent 中
Log.d("Dialog", "dispatchKeyEvent: keyCode=" + event.getKeyCode());
Log.d("Dialog", "mOnKeyListener=" + mOnKeyListener);

// 在 Dialog.onKeyDown 中
Log.d("Dialog", "onKeyDown called");
```

2. **觀察 log**:
```
D Dialog: dispatchKeyEvent: keyCode=7  // KEYCODE_0
D Dialog: mOnKeyListener=null
D Window: superDispatchKeyEvent returning true  // 被消費了
# 沒有 onKeyDown called 的 log
```

3. **定位問題**: dispatchKeyEvent 返回 false 或 Window 提前消費事件

## 問題分析

### Bug 1 分析
Dialog.dispatchKeyEvent() 應該在 Window 沒有消費事件時，調用 event.dispatch() 讓事件傳遞到 onKeyDown/onKeyUp callback。

### Bug 2 分析
Window.superDispatchKeyEvent() 應該返回 DecorView 的處理結果，而不是總是返回 true。

## 正確代碼

### 修復 Bug 1 (Dialog.java)
```java
@Override
public boolean dispatchKeyEvent(@NonNull KeyEvent event) {
    if ((mOnKeyListener != null) && (mOnKeyListener.onKey(this, event.getKeyCode(), event))) {
        return true;
    }
    if (mWindow.superDispatchKeyEvent(event)) {
        return true;
    }
    return event.dispatch(this, mDecor != null 
            ? mDecor.getKeyDispatcherState() : null, this);
}
```

### 修復 Bug 2 (Window.java/PhoneWindow)
```java
@Override
public boolean superDispatchKeyEvent(KeyEvent event) {
    return mDecor.superDispatchKeyEvent(event);
}
```

## 修復驗證

```bash
atest android.app.cts.AlertDialogTest#testCallback
```

## 難度分類理由

**Medium** - 需要理解 Android 的 key event 分發機制，追蹤從 Window 到 Dialog 的事件流，涉及兩個檔案的協作問題。
