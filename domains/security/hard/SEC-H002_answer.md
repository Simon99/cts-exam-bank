# SEC-H002 Answer: Verified Boot Hash 比對時序攻擊漏洞

## 正確答案
**A) 使用 `Arrays.equals()` 進行比較，它會在發現不匹配時提早返回**

## 問題根因
在 `RootOfTrust.java` 比對 verified boot hash 時，
使用了 `Arrays.equals()` 而非 `MessageDigest.isEqual()`。
`Arrays.equals()` 會在發現第一個不匹配的位元組時立即返回。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼（易受時序攻擊）
public boolean verifyHash(byte[] expectedHash) {
    return Arrays.equals(mVerifiedBootHash, expectedHash);  // BUG
}

// 正確的代碼（常數時間比較）
public boolean verifyHash(byte[] expectedHash) {
    return MessageDigest.isEqual(mVerifiedBootHash, expectedHash);
}
```

## 為什麼其他選項不對

**B)** `||` 短路運算會跳過評估，但這不太可能出現在位元組比較中。

**C)** `MessageDigest.isEqual()` 正是為了防止時序攻擊而設計的，
      標準實作沒有問題。

**D)** Hash 通常是 byte[]，直接用 String.equals() 會有型別問題。

## 相關知識
- 時序攻擊 (Timing Attack) 是一種側通道攻擊
- `Arrays.equals()` 是非常數時間的比較
- `MessageDigest.isEqual()` 保證常數時間執行
- 這對於密碼、雜湊、MAC 等秘密資料的比較很重要

## 難度說明
**Hard** - 需要理解時序攻擊和安全程式設計原則。
