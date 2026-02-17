# Q004: SslError.hasError() 對於 SSL_MAX_ERROR-1 的錯誤返回 false

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.http.cts.SslErrorTest#testHasErrorForInvalidCert

junit.framework.AssertionFailedError: 
Expected: true
Actual: false
    at android.net.http.cts.SslErrorTest.testHasErrorForInvalidCert(SslErrorTest.java:67)
```

## 測試代碼片段

```java
@Test
public void testHasErrorForInvalidCert() {
    SslCertificate cert = new SslCertificate("Test", "Test", new Date(), new Date());
    
    // 測試所有錯誤類型
    SslError error = new SslError(SslError.SSL_INVALID, cert, "https://test.com");
    
    assertTrue(error.hasError(SslError.SSL_NOTYETVALID));  // false (正確)
    assertTrue(error.hasError(SslError.SSL_INVALID));      // ← 預期 true，實際 false
}
```

## 問題描述

`SslError.hasError(int error)` 方法在檢查 `SSL_INVALID`（值為 5，是 `SSL_MAX_ERROR - 1`）時返回 false，但該錯誤確實存在於 error set 中。

## 相關代碼結構

`SslError.java` 中的常量和方法：
```java
public static final int SSL_NOTYETVALID = 0;
public static final int SSL_EXPIRED = 1;
public static final int SSL_IDMISMATCH = 2;
public static final int SSL_UNTRUSTED = 3;
public static final int SSL_DATE_INVALID = 4;
public static final int SSL_INVALID = 5;
public static final int SSL_MAX_ERROR = 6;

public boolean hasError(int error) {
    boolean rval = (0 <= error && error < SslError.SSL_MAX_ERROR);
    if (rval) {
        rval = ((mErrors & (0x1 << error)) != 0);
    }
    return rval;
}
```

## 任務

1. 分析 `addError()` 方法是如何設置 error bit 的
2. 分析 `hasError()` 方法是如何檢查 error bit 的
3. 找出為什麼 SSL_INVALID 的檢查會失敗
4. 修復問題

## 提示

- 涉及文件數：2（SslError.java, SslCertificate.java 作為相關類）
- 難度：Medium
- 關鍵字：addError、hasError、bitwise、SSL_MAX_ERROR
