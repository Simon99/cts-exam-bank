# SEC-E009: Bound Key Algorithm 檢查錯誤

## CTS Test
`android.keychain.cts.KeyChainTest#testIsBoundKeyAlgorithm`

## Failure Log
```
junit.framework.AssertionFailedError: EC should be bound key algorithm
Expected: true (EC is hardware-bound)
Actual: false

at android.keychain.cts.KeyChainTest.testIsBoundKeyAlgorithm(KeyChainTest.java:156)
```

## 現象描述
CTS 測試報告 `KeyChain.isBoundKeyAlgorithm("EC")` 返回 false，
但 EC 算法在現代設備上應該綁定到硬體安全模組。

## 提示
- Bound Key Algorithm 表示密鑰綁定到硬體
- 現代設備的 RSA 和 EC 都應該是 bound
- 問題可能在於條件檢查或返回值

## 選項

A) `isBoundKeyAlgorithm()` 只檢查 RSA，漏掉了 EC

B) `isBoundKeyAlgorithm()` 使用 `&&` 而非 `||` 連接條件

C) `isBoundKeyAlgorithm()` 中 EC 的字串比較使用了錯誤的常數

D) `isBoundKeyAlgorithm()` 返回了 `isKeyAlgorithmSupported()` 的反轉結果
