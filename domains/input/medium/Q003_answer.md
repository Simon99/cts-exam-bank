# Q003 Answer: MotionEvent getActionIndex() 回傳異常值

## 正確答案
**B) `getActionIndex()` 中使用左移 `<<` 而非右移 `>>`**

## 問題根因
在 `MotionEvent.java` 的 `getActionIndex()` 函數中，
位元操作方向錯誤：應該用右移 `>>` 將高位 index 移到低位，
但錯誤使用了左移 `<<`，導致值變得更大而非更小。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

```java
// 錯誤的代碼
public final int getActionIndex() {
    return (nativeGetAction(mNativePtr) & ACTION_POINTER_INDEX_MASK)
            << ACTION_POINTER_INDEX_SHIFT;  // BUG: 應該是 >>
}

// 正確的代碼
public final int getActionIndex() {
    return (nativeGetAction(mNativePtr) & ACTION_POINTER_INDEX_MASK)
            >> ACTION_POINTER_INDEX_SHIFT;
}
```

## 數值分析
- `ACTION_POINTER_INDEX_MASK = 0xff00`（高 8 位）
- `ACTION_POINTER_INDEX_SHIFT = 8`
- 正確時：`(0x0100 & 0xff00) >> 8 = 0x0100 >> 8 = 1`
- 錯誤時：`(0x0100 & 0xff00) << 8 = 0x0100 << 8 = 0x10000 = 65536`

## 為什麼其他選項不對

**A)** 用 `ACTION_MASK (0xff)` 會取到低 8 位（action type），回傳的是 action 類型而非 index，但不會產生 65536 這麼大的值。

**C)** 如果用 16 位右移，結果會是 0 而非 65536，因為右移會讓值變小。

**D)** 缺少 mask 但正確右移，結果會是 action 的高位值，最多幾百，不會是 65536。

## 相關知識
- Android action 編碼：低 8 位是 action type，次高 8 位是 pointer index
- 多點觸控時，`ACTION_POINTER_DOWN/UP` 需要配合 `getActionIndex()` 使用
- 位元右移用於從高位提取值，左移用於往高位設定值

## 難度說明
**Medium** - 需要理解位元運算和 action 編碼格式，從異常大的回傳值推斷左右移錯誤。
