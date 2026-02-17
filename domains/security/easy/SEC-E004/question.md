# SEC-E004: Key Size 驗證邊界錯誤

## CTS Test
`android.keystore.cts.AuthorizationListTest#testKeySize`

## Failure Log
```
junit.framework.AssertionFailedError: Key size validation failed
Expected: 2048 (valid RSA key size)
Actual: Reported as invalid key size

at android.keystore.cts.AuthorizationListTest.testKeySize(AuthorizationListTest.java:145)
```

## 現象描述
CTS 測試報告 2048 位元的 RSA 密鑰被錯誤地判定為無效大小。
但 2048 是 RSA 的標準密鑰大小。

## 提示
- RSA 常見密鑰大小：1024, 2048, 3072, 4096
- 邊界檢查通常使用 `<` 或 `<=`
- 問題可能在於比較運算符

## 選項

A) `validateKeySize()` 中使用 `keySize > MAX_KEY_SIZE` 而非 `keySize >= MAX_KEY_SIZE`

B) `validateKeySize()` 中使用 `keySize < MIN_KEY_SIZE` 而非 `keySize <= MIN_KEY_SIZE`

C) `validateKeySize()` 中將 `keySize >= 2048` 錯寫為 `keySize > 2048`

D) `validateKeySize()` 中 MIN_KEY_SIZE 常數設為 2049 而非 2048
