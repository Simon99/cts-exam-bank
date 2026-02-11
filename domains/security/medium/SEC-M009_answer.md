# SEC-M009 Answer: Network Security Config 憑證查找錯誤

## 正確答案
**A) `findBySubject()` 中使用 `==` 比較 X500Principal 而非 `equals()`**

## 問題根因
在 `CertificateSource.java` 的 `findBySubject()` 方法中，
比較 X500Principal 時使用了 `==` 而非 `equals()`。
由於是不同的物件實例，`==` 總是返回 false。

## Bug 位置
`frameworks/base/core/java/android/security/net/config/CertificateSource.java`

## 修復方式
```java
// 錯誤的代碼
public X509Certificate findBySubject(X500Principal subject) {
    for (X509Certificate cert : mCertificates) {
        if (cert.getSubjectX500Principal() == subject) {  // BUG
            return cert;
        }
    }
    return null;
}

// 正確的代碼
public X509Certificate findBySubject(X500Principal subject) {
    for (X509Certificate cert : mCertificates) {
        if (cert.getSubjectX500Principal().equals(subject)) {
            return cert;
        }
    }
    return null;
}
```

## 為什麼其他選項不對

**B)** 混淆 subject/issuer 會導致找到錯誤的憑證，但不會是 null（除非恰好沒有匹配）。

**C)** X500Principal.equals() 已經處理了標準化比較，不會有大小寫問題。

**D)** 如果繼續迴圈，至少會返回最後一個匹配項，不會是 null。

## 相關知識
- X500Principal 是 X.500 Distinguished Name 的 Java 表示
- 物件比較應該使用 equals() 而非 ==
- == 比較的是物件引用，equals() 比較的是內容

## 難度說明
**Medium** - 經典的物件比較錯誤，但需要理解 X.500 名稱比較。
