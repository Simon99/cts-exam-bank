# Q001 答案解析

## 正確答案：A

## 解析

### Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java` 的 `dispatch()` 方法，
`ACTION_MULTIPLE` case 分支。

### Bug 原因

原始正確代碼：
```java
case ACTION_MULTIPLE:
    final int count = mRepeatCount;
    final int code = mKeyCode;
    if (receiver.onKeyMultiple(code, count, this)) {
        return true;
    }
    if (code != KeyEvent.KEYCODE_UNKNOWN) {
        mAction = ACTION_DOWN;
        mRepeatCount = 0;
        boolean handled = receiver.onKeyDown(code, this);
        if (handled) {
            mAction = ACTION_UP;
            receiver.onKeyUp(code, this);
        }
        mAction = ACTION_MULTIPLE;    // ✓ 無論 handled 如何都恢復
        mRepeatCount = count;         // ✓ 無論 handled 如何都恢復
        return handled;
    }
    return false;
```

Bug 版本：
```java
if (handled) {
    mAction = ACTION_UP;
    receiver.onKeyUp(code, this);
    mAction = ACTION_MULTIPLE;    // ✗ 只在 handled 時恢復
    mRepeatCount = count;         // ✗ 只在 handled 時恢復
}
return handled;
```

當 `onKeyMultiple()` 返回 false 且 `onKeyDown()` 也返回 false 時：
- `handled = false`
- 不進入 `if (handled)` 分支
- `mAction` 保持為 `ACTION_DOWN`（臨時值）
- `mRepeatCount` 保持為 `0`（臨時值）
- KeyEvent 對象狀態被破壞

### 影響

1. **狀態污染**：KeyEvent 對象的 action 和 repeatCount 被永久修改
2. **後續處理錯誤**：其他代碼讀取這個 KeyEvent 會得到錯誤的 action
3. **事件重放失敗**：如果事件被記錄/重放，行為會不一致

### 為什麼其他選項錯誤

**B) 恢復順序錯誤**
恢復 `mAction` 和 `mRepeatCount` 的順序不影響結果，因為這兩個是獨立的欄位。

**C) KEYCODE_UNKNOWN 比較錯誤**
如果用 `==` 而不是 `!=`，會導致普通按鍵不進入 fallback 邏輯，
但 CTS log 顯示 onKeyDown 確實被調用了，所以比較是正確的。

**D) 漏掉 onKeyUp 調用**
Log 中沒有提到 onKeyUp 未被調用，且問題是狀態未恢復而非事件丟失。

## 修復建議

確保狀態恢復邏輯在 `if (handled)` 分支之外：
```java
if (handled) {
    mAction = ACTION_UP;
    receiver.onKeyUp(code, this);
}
// 這兩行必須在 if 之外
mAction = ACTION_MULTIPLE;
mRepeatCount = count;
return handled;
```
