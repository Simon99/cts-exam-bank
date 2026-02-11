# Q001 Answer: MotionEvent getActionMasked() 遮罩錯誤

## 正確答案
**B) `getActionMasked()` 中直接回傳 `mAction` 而沒有做遮罩運算**

## 問題根因
在 `MotionEvent.java` 的 `getActionMasked()` 函數中，
沒有使用 `ACTION_MASK` 做位元 AND 運算，直接回傳了原始的 `mAction` 值。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getActionMasked() {
    return mAction;  // BUG: 沒有做遮罩
}

// 正確的代碼
public final int getActionMasked() {
    return mAction & ACTION_MASK;
}
```

## 為什麼其他選項不對

**A)** `mAction | ACTION_MASK` 會把低 8 位全部變成 1，結果會是 0xFF 或更大。

**C)** `mAction & ~ACTION_MASK` 會取出高位（pointer index），結果是 256。

**D)** `ACTION_MASK = 0xFFFF` 會保留 16 位，但 261 < 0xFFFF，結果仍是 261，
這個選項效果與 B 在此案例相同，但 B 更直接。

## 相關知識
- MotionEvent action 編碼：低 8 位是動作類型，高 8 位是 pointer index
- `getAction()` 回傳完整值，`getActionMasked()` 只回傳動作類型
- 多點觸控需要用 `getActionMasked()` 配合 `getActionIndex()`

## 難度說明
**Medium** - 需要理解 action 的位元編碼結構，從 261 推算出包含了 pointer index。
