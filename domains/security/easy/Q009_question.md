# Q009: Bound Key Algorithm Check

## CTS Test
`android.security.cts.KeyChainTest#testIsBoundKeyAlgorithm`

## Failure Log
```
junit.framework.AssertionFailedError: 
KeyChain.isBoundKeyAlgorithm("EC") returned true
EC keys are not hardware-bound on this device
Expected: false
Actual: true

at android.security.cts.KeyChainTest.testIsBoundKeyAlgorithm(KeyChainTest.java:112)
```

## 現象描述
CTS 測試報告 `isBoundKeyAlgorithm()` 錯誤地返回 true。
此設備沒有硬體安全模組，EC 密鑰不應該被標記為硬體綁定。

## 提示
- isBoundKeyAlgorithm() 檢查密鑰是否綁定到硬體
- 需要查詢設備的安全能力
- 問題出在默認返回值

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// KeyChain.java
public static boolean isBoundKeyAlgorithm(@NonNull String algorithm) {
    if (algorithm == null) {
        return false;
    }
    
    try {
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);
        // Check if hardware-backed
        return isHardwareBacked(algorithm);
    } catch (Exception e) {
        Log.e(TAG, "Failed to check hardware backing", e);
        return true;  // LINE A
    }
}
```

A) KeyStore.getInstance() 應該使用不同的 provider
B) LINE A 應該返回 false 而非 true
C) 應該在調用 isHardwareBacked() 前檢查 keyStore
D) try-catch 應該分別處理不同的異常類型
