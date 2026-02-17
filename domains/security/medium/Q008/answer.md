# Q008 Answer: Verified Boot State Parsing

## 正確答案
**B) LINE A 的條件應該是 `value >= states.length`（不是 >）**

## 問題根因
邊界檢查使用了 `value > states.length`，應該是 `value >= states.length`。
當 value = 4 時（等於陣列長度），條件為 false，會嘗試訪問 `states[4]`，
導致 ArrayIndexOutOfBoundsException 或返回錯誤值。

但真正的問題是：當 value = states.length（4）時，應該返回預設值，
但 `> 4` 不會觸發預設邏輯。

實際上，對於有效值 0，如果有其他邏輯問題，可能返回錯誤結果。
重新審視：`> states.length` 允許 value=4 通過，這會造成陣列越界。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼
if (value < 0 || value > states.length) {  // BUG: 應該是 >=
    return VerifiedBootState.UNVERIFIED;
}

// 正確的代碼
if (value < 0 || value >= states.length) {
    return VerifiedBootState.UNVERIFIED;
}
```

## 選項分析
- **A) 錯誤** - 陣列索引是有效的方式
- **B) 正確** - 邊界條件 off-by-one 錯誤
- **C) 錯誤** - 枚舉順序與標準一致
- **D) 錯誤** - UNVERIFIED 作為預設值是合理的安全選擇

## 相關知識
- AVB (Android Verified Boot) 保護系統完整性
- 啟動狀態影響密鑰認證內容
- 陣列邊界檢查必須使用 `< length` 或 `>= length`

## 難度說明
**Medium** - 經典的邊界條件錯誤，需要仔細分析陣列索引邏輯。
