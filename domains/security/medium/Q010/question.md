# Q010: Certificate Source Lookup

## CTS Test
`android.security.cts.NetworkSecurityConfigTest#testCertificateSource`

## Failure Log
```
java.lang.SecurityException: 
Certificate not found by subject
Expected: Certificate with CN=TestCA should be found
Actual: findBySubject returned null

at android.security.net.config.CertificateSource.findBySubject(CertificateSource.java:89)
at android.security.cts.NetworkSecurityConfigTest.testCertificateSource(NetworkSecurityConfigTest.java:134)
```

## 現象描述
CTS 測試報告無法透過主體名稱找到憑證。憑證已經載入到信任儲存中，
但 findBySubject() 查詢返回 null。

## 提示
- X.500 主體名稱比較需要正規化
- 問題可能出在字串比較邏輯
- 注意 DN (Distinguished Name) 格式差異

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// CertificateSource.java
public X509Certificate findBySubject(X500Principal subject) {
    if (subject == null) {
        return null;
    }
    
    String subjectName = subject.getName();  // LINE A
    
    for (X509Certificate cert : certificates) {
        String certSubject = cert.getSubjectX500Principal().getName();
        if (subjectName.equals(certSubject)) {  // LINE B
            return cert;
        }
    }
    return null;
}
```

A) LINE A 應該使用 getName(X500Principal.RFC2253)
B) LINE B 應該使用 subject.equals(cert.getSubjectX500Principal())
C) 應該使用 HashMap 而非迴圈查詢
D) 應該比較 encoded bytes 而非字串
