# SEC-H001 Answer: Verified Boot Key 驗證哈希算法錯誤

## 正確答案
**A) `computeVerifiedBootKeyHash()` 中使用 `MessageDigest.getInstance("SHA-1")` 而非 `"SHA-256"`**

## 問題根因
在 `RootOfTrust.java` 的 `computeVerifiedBootKeyHash()` 方法中，
使用了過時的 SHA-1 算法而非規格要求的 SHA-256。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼
private byte[] computeVerifiedBootKeyHash(byte[] publicKey) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-1");  // BUG
        return digest.digest(publicKey);
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException(e);
    }
}

// 正確的代碼
private byte[] computeVerifiedBootKeyHash(byte[] publicKey) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        return digest.digest(publicKey);
    } catch (NoSuchAlgorithmException e) {
        throw new RuntimeException(e);
    }
}
```

## 為什麼其他選項不對

**B)** 截斷 32 bytes 到 20 bytes 需要顯式的陣列操作，
      這會在程式碼中很明顯，不太可能是意外錯誤。

**C)** Android 標準庫不預設支援 RIPEMD-160，
      需要額外的 Provider 才能使用。

**D)** 長度設定錯誤會影響雜湊內容，但不會改變輸出長度。
      SHA-256 無論輸入多長都輸出 32 bytes。

## 相關知識
- SHA-1 已被認為是不安全的，容易產生碰撞
- Android Verified Boot 2.0 規格要求 SHA-256
- 這類錯誤可能是從舊程式碼遷移時遺留的

## 難度說明
**Hard** - 需要理解密碼學基礎和 Verified Boot 規格。
