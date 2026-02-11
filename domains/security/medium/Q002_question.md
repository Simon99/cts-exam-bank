# Q002: KeyMaster Version Range Validation

## CTS Test
`android.keystore.cts.AttestationTest#testKeymasterVersion`

## Failure Log
```
junit.framework.AssertionFailedError: 
Invalid KeyMaster version reported
Version 50 is not a valid KeyMaster/KeyMint version
Expected: 10-41 (KeyMaster) or 100+ (KeyMint)
Actual: 50

at android.keystore.cts.AttestationTest.testKeymasterVersion(AttestationTest.java:167)
```

## 現象描述
CTS 測試報告 KeyMaster 版本 50 不在有效範圍內。有效版本應該是 10-41（KeyMaster）
或 100+（KeyMint），版本 50 不應該存在。

## 提示
- KeyMaster 版本：10, 11, 20, 30, 40, 41
- KeyMint 版本：100, 200, 300, ...
- 問題出在版本範圍驗證邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java
public void validateKeymasterVersion(int version) throws CertificateParsingException {
    // Valid versions: KeyMaster 10-41, KeyMint 100+
    if (version >= 10 && version <= 50) {  // LINE A
        return; // KeyMaster version - valid
    }
    if (version >= 100) {  // LINE B
        return; // KeyMint version - valid
    }
    throw new CertificateParsingException("Invalid KeyMaster version: " + version);
}
```

A) LINE A 的範圍應該是 `version <= 41`
B) LINE B 應該檢查 `version >= 100 && version <= 300`
C) 條件判斷應該使用 switch-case 而非 if
D) 應該先檢查 KeyMint 版本再檢查 KeyMaster 版本
