# Q002 Answer: Security Level Parsing

## 正確答案
**B) LINE A 應該返回 TRUSTED_ENVIRONMENT**

## 問題根因
在 `parseSecurityLevel()` 函數中，case 1 錯誤地返回了 `SecurityLevel.SOFTWARE`，
而實際上值 1 對應 `TRUSTED_ENVIRONMENT`。這是一個簡單的複製貼上錯誤。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
case 1:
    return SecurityLevel.SOFTWARE;  // BUG: 複製貼上錯誤

// 正確的代碼
case 1:
    return SecurityLevel.TRUSTED_ENVIRONMENT;
```

## 選項分析
- **A) 錯誤** - case 2 返回 STRONGBOX 是正確的
- **B) 正確** - case 1 應該返回 TRUSTED_ENVIRONMENT
- **C) 錯誤** - default 返回 SOFTWARE 是合理的容錯處理
- **D) 錯誤** - switch 結構本身沒問題，問題在於返回值

## 相關知識
- **SOFTWARE** - 密鑰在普通作業系統中處理，安全性最低
- **TRUSTED_ENVIRONMENT** - 密鑰在 TEE 中處理（如 ARM TrustZone）
- **STRONGBOX** - 密鑰在獨立安全處理器中處理，安全性最高
- CDD 要求正確報告設備實際的安全能力

## 難度說明
**Easy** - 典型的複製貼上錯誤，從 switch case 結構可直接看出問題。
