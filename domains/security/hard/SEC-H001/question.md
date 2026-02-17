# SEC-H001: Verified Boot Key 驗證哈希算法錯誤

## CTS Test
`android.keystore.cts.RootOfTrustTest#testVerifiedBootKey`

## Failure Log
```
junit.framework.AssertionFailedError: Verified boot key validation failed
Expected hash algorithm: SHA-256
Actual computed hash: Different length (20 bytes instead of 32)

The boot key hash appears to use SHA-1 instead of SHA-256.
at android.keystore.cts.RootOfTrustTest.testVerifiedBootKey(RootOfTrustTest.java:167)
```

## 相關測試上下文
```java
// 測試驗證 boot key 的雜湊值是否正確計算
byte[] expectedHash = computeHash(publicKey, "SHA-256");
byte[] actualHash = rootOfTrust.getVerifiedBootKey();
assertArrayEquals(expectedHash, actualHash);
```

## 現象描述
Root of Trust 中的 verified boot key 雜湊長度為 20 bytes，
但 SHA-256 應該產生 32 bytes。這表示使用了錯誤的哈希算法。

## 提示
- SHA-1 產生 160 bits (20 bytes) 的雜湊
- SHA-256 產生 256 bits (32 bytes) 的雜湊
- Verified Boot 規格要求使用 SHA-256

## 選項

A) `computeVerifiedBootKeyHash()` 中使用 `MessageDigest.getInstance("SHA-1")` 而非 `"SHA-256"`

B) 計算雜湊時截斷了結果，只取前 20 bytes

C) 使用了 RIPEMD-160 算法（也產生 20 bytes）

D) Boot key 的長度設定錯誤，導致只計算部分資料的雜湊
