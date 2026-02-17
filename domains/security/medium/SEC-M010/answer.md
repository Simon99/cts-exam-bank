# SEC-M010 Answer: SELinux Context 驗證字串解析錯誤

## 正確答案
**B) `split(":")` 限制只分割 3 次，遺漏了 range 部分**

## 問題根因
在 SELinux context 解析時，使用了 `split(":", 3)` 限制最多產生 3 個部分，
但正確的 context 有 4 個部分（user, role, type, range）。
應該使用 `split(":", 4)`。

## Bug 位置
`cts/hostsidetests/security/src/android/security/cts/SELinuxHostTest.java`

## 修復方式
```java
// 錯誤的代碼
public static String[] parseContext(String context) {
    return context.split(":", 3);  // BUG: 應該是 4
}

// 正確的代碼
public static String[] parseContext(String context) {
    return context.split(":", 4);
}
```

## 為什麼其他選項不對

**A)** 不限制分割次數會產生超過 4 個部分（如果 range 包含冒號），不符合「只有 3 個」的描述。

**C)** 索引從 1 開始會產生 ArrayIndexOutOfBoundsException，不會只是少一個元素。

**D)** 這描述的是過度分割（A 的情況），不是分割不足。

## 相關知識
- SELinux context: user:role:type:mls_range
- MLS range 格式：sensitivity[:category,category,...]
- String.split(regex, limit) 的 limit 參數控制最大分割數

## 難度說明
**Medium** - 需要理解 SELinux context 格式和 split 的 limit 參數。
