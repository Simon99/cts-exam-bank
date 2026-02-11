# Q007 Answer: KeyEvent 修飾鍵檢查錯誤

## 正確答案
**D) `isShiftPressed()` 中直接回傳 `false`**

## 問題根因
在 `KeyEvent.java` 的 `isShiftPressed()` 函數中，
沒有實際檢查 meta state，而是直接回傳 `false`。

## Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final boolean isShiftPressed() {
    return false;  // BUG: 直接回傳 false
}

// 正確的代碼
public final boolean isShiftPressed() {
    return (mMetaState & META_SHIFT_ON) != 0;
}
```

## 為什麼其他選項不對

**A)** OR 運算 `(meta | SHIFT)` 會讓結果幾乎總是非零（true），不會回傳 false。

**B)** 檢查 CTRL 位元時，如果 Shift 被按下但 CTRL 沒按，結果確實是 false，
但這個 bug 需要更多上下文才能確認，太複雜。

**C)** 使用 `!=` 而非 `==` 會讓邏輯反轉，但 `(meta & SHIFT) != 0` 本身是正確寫法。

## 相關知識
- KeyEvent 的 meta state 包含所有修飾鍵狀態
- 位元遮罩運算用於檢查特定位元
- 常見修飾鍵：Shift, Ctrl, Alt, Meta

## 難度說明
**Easy** - 總是回傳 false 的 bug 從 fail log 可直接判斷。
