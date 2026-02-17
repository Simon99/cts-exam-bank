# SEC-M002 Answer: Attestation Challenge 驗證長度錯誤

## 正確答案
**C) `parseChallenge()` 中的緩衝區大小設為 `length * 2` 而非 `length`**

## 問題根因
在 `Attestation.java` 的 `parseChallenge()` 方法中，
分配緩衝區時錯誤地將長度乘以 2，導致緩衝區過大，
後續的資料被錯誤地當成 challenge 的一部分。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
private byte[] parseChallenge(ASN1Encodable challengeValue, int length) {
    byte[] challenge = new byte[length * 2];  // BUG: 長度錯誤
    // ... 讀取邏輯 ...
    return challenge;
}

// 正確的代碼
private byte[] parseChallenge(ASN1Encodable challengeValue, int length) {
    byte[] challenge = new byte[length];
    // ... 讀取邏輯 ...
    return challenge;
}
```

## 為什麼其他選項不對

**A)** `<=` vs `<` 只會多讀一個位元組，不會剛好是兩倍。

**B)** 讀兩次會導致不確定行為，可能會讀到後續的資料，不一定是相同內容重複。

**D)** ByteBuffer.duplicate() 不會複製內容，只是創建一個共享緩衝區的視圖。

## 相關知識
- Attestation Challenge 用於綁定認證請求到特定會話
- 挑戰值通常是 32 或 64 位元組的隨機數
- 緩衝區大小錯誤是常見的記憶體操作錯誤

## 難度說明
**Medium** - 需要理解緩衝區操作和長度計算的關係。
