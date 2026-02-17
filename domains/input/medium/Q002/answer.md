# Q002 Answer: MotionEvent getActionIndex() 計算錯誤

## 正確答案
**C) `getActionIndex()` 中只做了 AND 遮罩沒有右移**

## 問題根因
在 `MotionEvent.java` 的 `getActionIndex()` 函數中，
使用 `ACTION_POINTER_INDEX_MASK` 做 AND 運算後，忘記右移 8 位取出實際的 index 值。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getActionIndex() {
    return mAction & ACTION_POINTER_INDEX_MASK;  // BUG: 沒有右移
    // mAction = 261 (5 | (1 << 8))
    // MASK = 0xFF00
    // 261 & 0xFF00 = 256
}

// 正確的代碼
public final int getActionIndex() {
    return (mAction & ACTION_POINTER_INDEX_MASK) >> ACTION_POINTER_INDEX_SHIFT;
    // (261 & 0xFF00) >> 8 = 256 >> 8 = 1
}
```

## 為什麼其他選項不對

**A)** 左移會讓結果變成更大的數（256 << 8 = 65536），不是 256。

**B)** 遮罩值錯誤會產生不同的結果，但這裡的 256 剛好是正確遮罩沒右移的結果。

**D)** `261 % 256 = 5`，這是動作類型不是 index。

## 相關知識
- MotionEvent action 編碼結構
- `ACTION_POINTER_INDEX_MASK = 0xFF00`
- `ACTION_POINTER_INDEX_SHIFT = 8`

## 難度說明
**Medium** - 需要理解位元運算，從 256 = 1 << 8 推算出缺少右移操作。
