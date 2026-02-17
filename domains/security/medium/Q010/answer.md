# Q010 Answer: Certificate Source Lookup

## 正確答案
**B) LINE B 應該使用 subject.equals(cert.getSubjectX500Principal())**

## 問題根因
`X500Principal.getName()` 返回的字串格式可能因實作而異，導致相同的主體名稱
產生不同的字串表示。例如：
- "CN=TestCA, O=Test, C=US" vs "CN=TestCA,O=Test,C=US"（空格差異）
- 屬性順序可能不同

正確做法是使用 `X500Principal.equals()`，它會正確處理 DN 的規範化比較。

## Bug 位置
`frameworks/base/core/java/android/security/net/config/CertificateSource.java`

## 修復方式
```java
// 錯誤的代碼
String subjectName = subject.getName();
for (X509Certificate cert : certificates) {
    String certSubject = cert.getSubjectX500Principal().getName();
    if (subjectName.equals(certSubject)) {  // 字串比較可能失敗
        return cert;
    }
}

// 正確的代碼
for (X509Certificate cert : certificates) {
    if (subject.equals(cert.getSubjectX500Principal())) {  // 使用 X500Principal.equals()
        return cert;
    }
}
```

## 選項分析
- **A) 部分正確** - 指定格式可能有幫助，但不是根本解決方案
- **B) 正確** - X500Principal.equals() 正確處理 DN 比較
- **C) 錯誤** - 使用 Map 需要正確的 hashCode/equals，問題一樣
- **D) 部分正確** - encoded bytes 可行，但 equals() 更簡潔

## 相關知識
- X.500 Distinguished Name 有多種字串格式（RFC 2253, RFC 1779）
- X500Principal.equals() 比較的是 DER 編碼的位元組
- 網路安全配置用於自訂信任錨點

## 難度說明
**Medium** - 需要了解 X.500 主體名稱的比較問題。
