# Q010: SslCertificate.restoreState() 恢復後 getValidNotBefore() 返回 null

## CTS 測試失敗信息

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.net.http.cts.SslCertificateTest#testSaveAndRestoreState

junit.framework.AssertionFailedError: 
Expected: "2024-01-01 00:00:00+0800"
Actual: null
    at android.net.http.cts.SslCertificateTest.testSaveAndRestoreState(SslCertificateTest.java:87)
```

## 測試代碼片段

```java
@Test
public void testSaveAndRestoreState() {
    // 創建原始證書
    Date notBefore = parseDate("2024-01-01 00:00:00+0800");
    Date notAfter = parseDate("2025-01-01 00:00:00+0800");
    SslCertificate original = new SslCertificate("Issued To", "Issued By", notBefore, notAfter);
    
    // 保存狀態
    Bundle bundle = SslCertificate.saveState(original);
    assertNotNull(bundle);
    
    // 恢復狀態
    SslCertificate restored = SslCertificate.restoreState(bundle);
    assertNotNull(restored);
    
    // 驗證恢復的值
    assertEquals(original.getIssuedTo().getDName(), restored.getIssuedTo().getDName());  // ← 通過
    assertEquals(original.getValidNotBefore(), restored.getValidNotBefore());  // ← 失敗！
    assertEquals(original.getValidNotAfter(), restored.getValidNotAfter());    // ← 通過
}
```

## 問題描述

使用 `saveState()` 和 `restoreState()` 保存和恢復 `SslCertificate` 時，`getValidNotBefore()` 返回 null，但其他字段都正確恢復。

## 相關代碼結構

`SslCertificate.java`:
```java
public static Bundle saveState(SslCertificate certificate) {
    Bundle bundle = new Bundle();
    bundle.putString(ISSUED_TO, certificate.getIssuedTo().getDName());
    bundle.putString(ISSUED_BY, certificate.getIssuedBy().getDName());
    bundle.putString(VALID_NOT_BEFORE, certificate.getValidNotBefore());
    bundle.putString(VALID_NOT_AFTER, certificate.getValidNotAfter());
    // ...
}

public static SslCertificate restoreState(Bundle bundle) {
    return new SslCertificate(bundle.getString(ISSUED_TO),
                              bundle.getString(ISSUED_BY),
                              parseDate(bundle.getString(VALID_NOT_BEFORE)),
                              parseDate(bundle.getString(VALID_NOT_AFTER)),
                              x509Certificate);
}
```

## 任務

1. 比較 `saveState()` 和 `restoreState()` 中的 key 使用
2. 找出為什麼 VALID_NOT_BEFORE 沒有正確恢復
3. 修復問題

## 提示

- 涉及文件數：2（SslCertificate.java 及其測試邏輯）
- 難度：Medium
- 關鍵字：saveState、restoreState、Bundle、key mismatch
