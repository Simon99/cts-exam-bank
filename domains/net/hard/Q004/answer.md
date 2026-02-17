# Q004 解答：SslCertificate 從 X509Certificate 創建時日期解析錯誤

## 問題根因

問題涉及三個檔案的交互：
1. `SslCertificate.java` 構造函數參數順序錯誤
2. `SslError.java` 使用錯誤的方法檢查日期
3. `X509TrustManagerExtensions.java` 沒有執行日期驗證

## Bug 位置

1. **SslCertificate.java** - 構造函數
2. **SslError.java** - hasDateError()
3. **X509TrustManagerExtensions.java** - validateCertificateDates()

## 錯誤代碼 - SslCertificate.java

```java
public SslCertificate(X509Certificate certificate) {
    this(certificate.getSubjectDN().getName(),
         certificate.getIssuerDN().getName(),
         certificate.getNotAfter(),    // Bug: 應該是 getNotBefore()
         certificate.getNotBefore(),   // Bug: 應該是 getNotAfter()
         certificate);
}
```

## 錯誤代碼 - SslError.java

```java
public boolean hasDateError() {
    SslCertificate cert = getCertificate();
    // BUG: 使用字串方法而非日期方法
    return cert.getValidNotBefore() == null || cert.getValidNotAfter() == null;
}
```

## 錯誤代碼 - X509TrustManagerExtensions.java

```java
private void validateCertificateDates(X509Certificate cert) {
    // BUG: 沒有執行任何驗證
    // 允許過期或未生效的證書通過
}
```

## 修復方案

### SslCertificate.java
```java
public SslCertificate(X509Certificate certificate) {
    this(certificate.getSubjectDN().getName(),
         certificate.getIssuerDN().getName(),
         certificate.getNotBefore(),   // 正確順序
         certificate.getNotAfter(),    // 正確順序
         certificate);
}
```

### SslError.java
```java
public boolean hasDateError() {
    SslCertificate cert = getCertificate();
    Date now = new Date();
    Date notBefore = cert.getValidNotBeforeDate();
    Date notAfter = cert.getValidNotAfterDate();
    return now.before(notBefore) || now.after(notAfter);
}
```

### X509TrustManagerExtensions.java
```java
private void validateCertificateDates(X509Certificate cert) throws CertificateException {
    Date now = new Date();
    if (now.before(cert.getNotBefore())) {
        throw new CertificateException("Certificate not yet valid");
    }
    if (now.after(cert.getNotAfter())) {
        throw new CertificateException("Certificate expired");
    }
}
```

## X509Certificate 日期說明

| 方法 | 含義 |
|------|------|
| `getNotBefore()` | 證書生效日期（開始日期）|
| `getNotAfter()` | 證書過期日期（結束日期）|

## 驗證命令

```bash
atest android.net.http.cts.SslCertificateTest#testX509CertificateDates
```

## 學習要點

- 構造函數參數順序很重要
- notBefore/notAfter 名稱容易混淆
- 日期驗證需要多層保護
