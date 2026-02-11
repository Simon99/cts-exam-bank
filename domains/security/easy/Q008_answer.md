# Q008 Answer: Key Algorithm Support Check

## 正確答案
**C) LINE B 應該將 algorithm 轉為小寫後再比較**

## 問題根因
`SUPPORTED_ALGORITHMS` 使用小寫存儲算法名稱（"rsa", "ec", "aes"），
但 `isKeyAlgorithmSupported()` 直接比較輸入字串，沒有進行大小寫轉換。

當調用 `isKeyAlgorithmSupported("RSA")` 時，由於 "RSA" ≠ "rsa"，返回 false。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
return SUPPORTED_ALGORITHMS.contains(algorithm);

// 正確的代碼
return SUPPORTED_ALGORITHMS.contains(algorithm.toLowerCase(Locale.US));
```

## 選項分析
- **A) 部分正確** - 改用大寫可解決，但不如統一轉換健壯
- **B) 錯誤** - Set.contains() 不支持 equalsIgnoreCase
- **C) 正確** - 統一轉小寫是標準做法，最健壯
- **D) 錯誤** - B 不可行，所以並非全部皆可

## 相關知識
- 算法名稱大小寫在不同 API 中可能不一致
- 使用 Locale.US 避免土耳其語 i 問題
- 良好的 API 設計應該對大小寫不敏感

## 難度說明
**Easy** - 典型的大小寫比較問題，從 fail log 的 "RSA" vs "rsa" 即可推斷。
