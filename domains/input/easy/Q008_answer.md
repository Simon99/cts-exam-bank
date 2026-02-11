# Q008 Answer: KeyEvent 重複次數計算錯誤

## 正確答案
**C) `getRepeatCount()` 中直接回傳 0**

## 問題根因
在 `KeyEvent.java` 的 `getRepeatCount()` 函數中，
沒有回傳實際的重複次數 `mRepeatCount`，而是直接回傳 0。

## Bug 位置
`frameworks/base/core/java/android/view/KeyEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getRepeatCount() {
    return 0;  // BUG: 直接回傳 0
}

// 正確的代碼
public final int getRepeatCount() {
    return mRepeatCount;
}
```

## 為什麼其他選項不對

**A)** `Math.abs(5)` = 5，不會變成 0。

**B)** `5 % 1` = 0，數學上正確，但這種寫法太不自然。

**D)** `5 >> 8` = 0，這需要數值超過 256 才會有非零結果，但太刻意。

## 相關知識
- KeyEvent 的重複計數用於長按偵測
- 第一個 KEY_DOWN 事件 repeat count 為 0
- 後續重複事件 repeat count 遞增

## 難度說明
**Easy** - 直接回傳 0 是最簡單的 bug，從 log 可直接確認。
