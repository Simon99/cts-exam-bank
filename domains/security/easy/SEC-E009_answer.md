# SEC-E009 Answer: Bound Key Algorithm 檢查錯誤

## 正確答案
**A) `isBoundKeyAlgorithm()` 只檢查 RSA，漏掉了 EC**

## 問題根因
在 `KeyChain.java` 的 `isBoundKeyAlgorithm()` 方法中，
只檢查了 RSA 算法，遺漏了 EC 算法的判斷。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
public static boolean isBoundKeyAlgorithm(@NonNull String algorithm) {
    return KeyProperties.KEY_ALGORITHM_RSA.equals(algorithm);
    // BUG: 漏掉 EC
}

// 正確的代碼
public static boolean isBoundKeyAlgorithm(@NonNull String algorithm) {
    return KeyProperties.KEY_ALGORITHM_RSA.equals(algorithm)
            || KeyProperties.KEY_ALGORITHM_EC.equals(algorithm);
}
```

## 為什麼其他選項不對

**B)** 使用 `&&` 會要求同時滿足 RSA 和 EC，這不合邏輯，任何算法都會返回 false。

**C)** 如果是常數錯誤，通常會在編譯時或其他測試發現。

**D)** 反轉 isKeyAlgorithmSupported 會導致支援的算法反而返回 false，但 RSA 也應該出問題。

## 相關知識
- Bound Key 表示密鑰綁定到特定硬體
- 這提供了更高的安全性，密鑰無法被提取
- TEE 和 StrongBox 都支援 bound keys

## 難度說明
**Easy** - 遺漏一個條件分支是常見的實作錯誤。
