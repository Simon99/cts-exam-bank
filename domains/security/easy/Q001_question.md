# Q001: Key Attestation Extension Check

## CTS Test
`android.keystore.cts.AttestationTest#testEcAttestation`

## Failure Log
```
java.lang.SecurityException: Invalid attestation extension format
Expected EAT or ASN.1 attestation extension not found

at android.keystore.cts.Attestation.loadFromCertificate(Attestation.java:82)
at android.keystore.cts.AttestationTest.testEcAttestation(AttestationTest.java:156)
```

## 現象描述
CTS 測試報告無法載入有效的密鑰認證擴展。系統顯示憑證中沒有找到預期的 EAT 或 ASN.1 認證擴展格式。

## 提示
- 密鑰認證擴展有兩種格式：EAT (Entity Attestation Token) 和 ASN.1
- 應該優先檢查 EAT 格式，再檢查 ASN.1 格式
- 問題出在擴展格式檢查的順序或條件

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java - loadFromCertificate()
public static Attestation loadFromCertificate(X509Certificate x509Cert) {
    byte[] eatExtension = x509Cert.getExtensionValue(EAT_EXTENSION_OID);
    byte[] asn1Extension = x509Cert.getExtensionValue(ASN1_EXTENSION_OID);
    
    if (eatExtension != null || asn1Extension != null) {  // LINE A
        return parseEatAttestation(eatExtension);
    } else if (asn1Extension != null) {  // LINE B
        return parseAsn1Attestation(asn1Extension);
    }
    throw new SecurityException("Invalid attestation extension format");
}
```

A) LINE A 的條件應該是 `eatExtension != null && asn1Extension != null`
B) LINE A 的條件應該只檢查 `eatExtension != null`
C) LINE B 永遠不會被執行到
D) 應該先檢查 `asn1Extension` 再檢查 `eatExtension`
