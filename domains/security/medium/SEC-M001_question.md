# SEC-M001: Attestation Certificate 解析異常處理錯誤

## CTS Test
`android.keystore.cts.AttestationTest#testLoadFromInvalidCertificate`

## Failure Log
```
java.lang.NullPointerException: Attempt to invoke virtual method on null object reference
at android.keystore.cts.Attestation.loadFromCertificate(Attestation.java:82)
at android.keystore.cts.AttestationTest.testLoadFromInvalidCertificate(AttestationTest.java:178)

Expected: CertificateParsingException
Actual: NullPointerException
```

## 現象描述
當傳入無效的 X509 憑證時，`loadFromCertificate()` 應該拋出 `CertificateParsingException`，
但實際上拋出了 `NullPointerException`。這表示異常處理邏輯有問題。

## 提示
- 解析失敗應該拋出特定的異常類型
- NullPointerException 通常表示未檢查 null 值
- 問題可能在於 getExtensionValue 返回 null 時的處理

## 選項

A) `loadFromCertificate()` 在 `getExtensionValue()` 返回 null 後沒有檢查，直接使用

B) `loadFromCertificate()` 在 catch 區塊中沒有正確轉換異常類型

C) `loadFromCertificate()` 使用了錯誤的異常類型 `IOException` 而非 `CertificateParsingException`

D) `loadFromCertificate()` 在解析失敗時返回 null 而非拋出異常
