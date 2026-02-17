# Q006 Answer: KeyEvent 按鍵碼回傳錯誤

## 正確答案
**B) `getKeyCode()` 中回傳固定值 `KEYCODE_UNKNOWN`**

## 問題根因
在 `KeyEvent.java` 的 `getKeyCode()` 函數中，
回傳了固定常數 `KEYCODE_UNKNOWN` 而非實際的按鍵碼 `mKeyCode`。

## Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getKeyCode() {
    return KEYCODE_UNKNOWN;  // BUG: 回傳固定值
}

// 正確的代碼
public final int getKeyCode() {
    return mKeyCode;
}
```

## 為什麼其他選項不對

**A)** scan code 是硬體層的按鍵碼，通常不為 0，回傳它會得到非 0 值。

**C)** `mKeyCode & 0` 確實會得到 0，但這種寫法太刻意，不太可能是真實 bug。

**D)** static 變數問題會導致所有實例共用同一個值，但不會讓值變成 0。

## 相關知識
- KeyEvent 包含 keyCode（邏輯按鍵碼）和 scanCode（硬體掃描碼）
- KEYCODE_UNKNOWN (0) 表示未知按鍵
- Android 按鍵碼定義在 KeyEvent 類別中

## 難度說明
**Easy** - 回傳固定值是簡單的硬編碼錯誤，從 log 直接可見。
