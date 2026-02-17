# Q010 Answer: InputDevice supportsSource() 檢查錯誤

## 正確答案
**C) `supportsSource()` 中的比較結果取反 (`!`)**

## 問題根因
在 `InputDevice.java` 的 `supportsSource()` 函數中，
正確的位元運算後，結果被錯誤地取反。

## Bug 位置
`frameworks/base/core/java/android/view/InputDevice.java`

## 修復方式
```java
// 錯誤的代碼
public boolean supportsSource(int source) {
    return !((mSources & source) == source);  // BUG: 多了 !
}

// 正確的代碼
public boolean supportsSource(int source) {
    return (mSources & source) == source;
}
```

## 為什麼其他選項不對

**A)** `sources | source` 會讓結果總是包含 source 位元，結果會是 true。

**B)** 使用 `!= 0` 檢查也是正確的寫法之一，不會造成這個問題：
```java
// 這兩種寫法都正確：
(sources & source) == source  // 精確匹配
(sources & source) != 0       // 部分匹配
```

**D)** `~source` 會得到反向遮罩，AND 運算後結果會是沒有 source 位元的部分。

## 相關知識
- InputDevice 的 source 標識輸入類型
- 常見 source：TOUCHSCREEN, KEYBOARD, MOUSE
- 位元運算用於檢查旗標

## 難度說明
**Medium** - 需要理解位元運算和布林邏輯，分析為何正確變錯誤。
