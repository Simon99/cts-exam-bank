# Q001: Certificate Attestation Loading

## CTS Test
`android.keystore.cts.AttestationTest#testLoadFromCertificate`

## Failure Log
```
java.lang.SecurityException: Failed to parse attestation extension
Unable to decode ASN.1 sequence from certificate extension

at android.keystore.cts.Attestation.loadFromCertificate(Attestation.java:92)
at android.keystore.cts.AttestationTest.testLoadFromCertificate(AttestationTest.java:134)
```

## 現象描述
CTS 測試報告無法從憑證載入認證資料。認證擴展存在於憑證中，但解析 ASN.1 結構時失敗。

## 提示
- 憑證擴展值需要先解除包裝（unwrap）
- X.509 擴展值本身是一個 OCTET STRING
- 問題出在解析前的資料處理

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java
public static Attestation loadFromCertificate(X509Certificate x509Cert) 
        throws CertificateParsingException {
    byte[] extensionValue = x509Cert.getExtensionValue(ATTESTATION_EXTENSION_OID);
    
    if (extensionValue == null) {
        throw new CertificateParsingException("No attestation extension");
    }
    
    try {
        ASN1Sequence sequence = (ASN1Sequence) ASN1Primitive.fromByteArray(extensionValue);  // LINE A
        return parseAttestationSequence(sequence);
    } catch (Exception e) {
        throw new SecurityException("Failed to parse attestation extension", e);
    }
}
```

A) 應該使用 ASN1InputStream 而非 ASN1Primitive.fromByteArray()
B) extensionValue 是 OCTET STRING 包裝，需要先解包再解析
C) 應該檢查 sequence 是否為 null 再調用 parseAttestationSequence
D) ATTESTATION_EXTENSION_OID 常數值可能錯誤
