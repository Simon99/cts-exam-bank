# Q004: SslCertificate 從 X509Certificate 創建時日期解析錯誤

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.http.cts.SslCertificateTest#testX509CertificateDates

junit.framework.AssertionFailedError: 
Certificate dates don't match
Expected NotBefore: 2024-01-01
Actual NotBefore: 2025-01-01
    at android.net.http.cts.SslCertificateTest.testX509CertificateDates(SslCertificateTest.java:134)
```

## 測試代碼片段

```java
@Test
public void testX509CertificateDates() throws Exception {
    // 創建測試證書
    X509Certificate x509 = createTestCertificate(
        parseDate("2024-01-01"),  // notBefore
        parseDate("2025-01-01")   // notAfter
    );
    
    // 從 X509Certificate 創建 SslCertificate
    SslCertificate sslCert = new SslCertificate(x509);
    
    // 驗證日期
    Date notBefore = sslCert.getValidNotBeforeDate();
    Date notAfter = sslCert.getValidNotAfterDate();
    
    assertEquals(parseDate("2024-01-01"), notBefore);  // ← 失敗！返回 2025-01-01
    assertEquals(parseDate("2025-01-01"), notAfter);   // ← 通過
}
```

## 問題描述

從 `X509Certificate` 創建 `SslCertificate` 時，`notBefore` 和 `notAfter` 的日期被弄反了。

## 相關代碼結構

`SslCertificate.java`:
```java
public SslCertificate(X509Certificate certificate) {
    this(certificate.getSubjectDN().getName(),
         certificate.getIssuerDN().getName(),
         certificate.getNotBefore(),
         certificate.getNotAfter(),
         certificate);
}

private SslCertificate(String issuedTo, String issuedBy, 
                       Date validNotBefore, Date validNotAfter,
                       X509Certificate x509Certificate) {
    mIssuedTo = new DName(issuedTo);
    mIssuedBy = new DName(issuedBy);
    mValidNotBefore = cloneDate(validNotBefore);
    mValidNotAfter = cloneDate(validNotAfter);
    mX509Certificate = x509Certificate;
}
```

`SslError.java` 使用 `SslCertificate`:
```java
public SslError(int error, X509Certificate certificate, String url) {
    this(error, new SslCertificate(certificate), url);
}
```

## 任務

1. 追蹤 `SslCertificate` 的構造函數
2. 檢查從 X509Certificate 到 SslCertificate 的數據映射
3. 找出日期被交換的位置
4. 修復問題

## 提示

- 涉及文件數：3（SslCertificate.java, SslError.java, X509Certificate 相關）
- 難度：Hard
- 關鍵字：SslCertificate、X509Certificate、getNotBefore、getNotAfter
- 呼叫鏈：SslError → SslCertificate(X509Certificate) → private 構造函數
