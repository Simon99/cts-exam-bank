# SEC-E008: KeyChain 算法支援檢查錯誤

## CTS Test
`android.keychain.cts.KeyChainTest#testIsKeyAlgorithmSupported`

## Failure Log
```
junit.framework.AssertionFailedError: RSA algorithm should be supported
Expected: true
Actual: false

at android.keychain.cts.KeyChainTest.testIsKeyAlgorithmSupported(KeyChainTest.java:134)
```

## 現象描述
CTS 測試報告 `KeyChain.isKeyAlgorithmSupported("RSA")` 返回 false，
但 RSA 是所有 Android 設備都必須支援的基本算法。

## 提示
- KeyChain 提供系統級的密鑰管理
- 支援的算法：RSA, EC
- 問題可能在於字串比較或返回邏輯

## 選項

A) `isKeyAlgorithmSupported()` 使用 `==` 比較字串而非 `equals()`

B) `isKeyAlgorithmSupported()` 中 RSA 的比較字串拼寫錯誤

C) `isKeyAlgorithmSupported()` 對所有輸入都返回 false

D) `isKeyAlgorithmSupported()` 中的 if-else 邏輯順序錯誤
