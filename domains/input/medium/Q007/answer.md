# Q007 Answer: KeyEvent getMetaState() 修飾鍵狀態錯誤

## 正確答案
**A) `getMetaState()` 中使用 `mMetaState & META_SHIFT_ON` 只取 Shift 位元**

## 問題根因
在 `KeyEvent.java` 的 `getMetaState()` 函數中，
錯誤地使用 AND 遮罩只保留 Shift 位元，遺失了其他修飾鍵狀態。

## Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getMetaState() {
    return mMetaState & META_SHIFT_ON;  // BUG: 只保留 Shift 位元
    // 0x41 & 0x01 = 0x01
}

// 正確的代碼
public final int getMetaState() {
    return mMetaState;
}
```

## 為什麼其他選項不對

**B)** `mMetaState | 0` 等於 `mMetaState`，不會遺失任何位元。

**C)** 右移會讓所有位元位置改變，結果不會是 0x01。

**D)** 如果 META_CTRL_ON=0，那 0x41 | 0 = 0x41，結果不會變成 0x01。

## 相關知識
- KeyEvent meta state 是位元旗標的組合
- 常見修飾鍵：Shift, Ctrl, Alt, Meta, Caps Lock
- 位元 OR (`|`) 用於組合，AND (`&`) 用於檢查

## 難度說明
**Medium** - 需要理解位元運算，分析 0x41 如何變成 0x01 (AND 遮罩)。
