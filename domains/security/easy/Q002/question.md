# Q002: Security Level Parsing

## CTS Test
`android.keystore.cts.AttestationTest#testSecurityLevel`

## Failure Log
```
junit.framework.AssertionFailedError: 
Expected security level: TRUSTED_ENVIRONMENT
Actual security level: SOFTWARE
Key attestation reports incorrect security level

at android.keystore.cts.AttestationTest.testSecurityLevel(AttestationTest.java:203)
```

## 現象描述
CTS 測試報告密鑰認證的安全等級不正確。設備具有硬體安全模組 (TEE)，
但認證報告的安全等級顯示為 SOFTWARE 而非 TRUSTED_ENVIRONMENT。

## 提示
- 安全等級有三種：SOFTWARE (0), TRUSTED_ENVIRONMENT (1), STRONGBOX (2)
- 安全等級從認證擴展中的數值解析而來
- 問題出在數值到枚舉的對應邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java
public enum SecurityLevel {
    SOFTWARE,           // 0
    TRUSTED_ENVIRONMENT, // 1
    STRONGBOX           // 2
}

private SecurityLevel parseSecurityLevel(int value) {
    switch (value) {
        case 0:
            return SecurityLevel.SOFTWARE;
        case 1:
            return SecurityLevel.SOFTWARE;  // LINE A
        case 2:
            return SecurityLevel.STRONGBOX;
        default:
            return SecurityLevel.SOFTWARE;
    }
}
```

A) case 2 應該返回 TRUSTED_ENVIRONMENT
B) LINE A 應該返回 TRUSTED_ENVIRONMENT
C) default 應該拋出異常而非返回 SOFTWARE
D) switch 應該改用 if-else 結構
