# SEC-E008 Answer: KeyChain 算法支援檢查錯誤

## 正確答案
**C) `isKeyAlgorithmSupported()` 對所有輸入都返回 false**

## 問題根因
在 `KeyChain.java` 的 `isKeyAlgorithmSupported()` 方法中，
直接返回 false，沒有實際檢查算法是否支援。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
public static boolean isKeyAlgorithmSupported(String algorithm) {
    return false;  // BUG: 直接返回 false
}

// 正確的代碼
public static boolean isKeyAlgorithmSupported(String algorithm) {
    return KeyProperties.KEY_ALGORITHM_RSA.equals(algorithm)
            || KeyProperties.KEY_ALGORITHM_EC.equals(algorithm);
}
```

## 為什麼其他選項不對

**A)** 使用 `==` 比較字串在某些情況下可能成功（字串池），不會總是 false。

**B)** 拼寫錯誤只會影響特定算法，如果 EC 正常則可排除此選項。

**D)** if-else 順序錯誤會導致某些算法被錯誤判斷，但不會全部返回 false。

## 相關知識
- KeyChain 是 Android 系統級密鑰管理 API
- RSA 和 EC 是必須支援的非對稱加密算法
- 這個 API 用於判斷設備支援哪些算法

## 難度說明
**Easy** - 直接返回 false 是最簡單的硬編碼錯誤。
