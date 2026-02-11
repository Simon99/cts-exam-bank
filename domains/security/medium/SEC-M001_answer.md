# SEC-M001 Answer: Attestation Certificate 解析異常處理錯誤

## 正確答案
**A) `loadFromCertificate()` 在 `getExtensionValue()` 返回 null 後沒有檢查，直接使用**

## 問題根因
在 `Attestation.java` 的 `loadFromCertificate()` 方法中，
當 `getExtensionValue()` 返回 null（表示憑證沒有預期的擴展）時，
沒有先檢查就直接對 null 值進行操作，導致 NullPointerException。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
public static Attestation loadFromCertificate(X509Certificate x509Cert)
        throws CertificateParsingException {
    byte[] attestationExtension = x509Cert.getExtensionValue(ASN1_OID);
    // BUG: 沒有 null 檢查，直接使用
    return parseExtension(attestationExtension);
}

// 正確的代碼
public static Attestation loadFromCertificate(X509Certificate x509Cert)
        throws CertificateParsingException {
    byte[] attestationExtension = x509Cert.getExtensionValue(ASN1_OID);
    if (attestationExtension == null) {
        throw new CertificateParsingException(
                "Certificate does not contain attestation extension");
    }
    return parseExtension(attestationExtension);
}
```

## 為什麼其他選項不對

**B)** 異常轉換問題會產生包裝過的異常，通常 cause 會是原始異常，stack trace 會有所不同。

**C)** 使用錯誤的異常類型會拋出 IOException，不是 NullPointerException。

**D)** 返回 null 會讓調用者得到 null，後續調用才會產生 NullPointerException，stack trace 會不同。

## 相關知識
- X509Certificate.getExtensionValue() 在擴展不存在時返回 null
- 防禦性程式設計要求檢查可能為 null 的返回值
- 異常類型應該與 API 文檔一致

## 難度說明
**Medium** - 需要理解 null 處理和異常設計的關係。
