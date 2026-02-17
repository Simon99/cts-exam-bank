# Q008: Key Algorithm Support Check

## CTS Test
`android.security.cts.KeyChainTest#testIsKeyAlgorithmSupported`

## Failure Log
```
junit.framework.AssertionFailedError: 
KeyChain.isKeyAlgorithmSupported("RSA") returned false
RSA algorithm should be supported on all devices

at android.security.cts.KeyChainTest.testIsKeyAlgorithmSupported(KeyChainTest.java:98)
```

## 現象描述
CTS 測試報告 RSA 算法被錯誤地標記為不支援。
根據 CDD 要求，所有 Android 設備都必須支援 RSA 和 EC 算法。

## 提示
- isKeyAlgorithmSupported() 檢查設備是否支援特定算法
- 問題出在字串比較邏輯
- 注意大小寫處理

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// KeyChain.java
private static final Set<String> SUPPORTED_ALGORITHMS = new HashSet<>(
    Arrays.asList("rsa", "ec", "aes")  // LINE A
);

public static boolean isKeyAlgorithmSupported(@NonNull String algorithm) {
    if (algorithm == null) {
        return false;
    }
    return SUPPORTED_ALGORITHMS.contains(algorithm);  // LINE B
}
```

A) SUPPORTED_ALGORITHMS 應該包含 "RSA" 而非 "rsa"
B) LINE B 應該使用 equalsIgnoreCase 比較
C) LINE B 應該將 algorithm 轉為小寫後再比較
D) 以上皆可解決問題
