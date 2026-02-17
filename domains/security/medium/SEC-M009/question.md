# SEC-M009: Network Security Config 憑證查找錯誤

## CTS Test
`android.security.net.cts.NetworkSecurityConfigTest#testCertificateFindBySubject`

## Failure Log
```
junit.framework.AssertionFailedError: Certificate lookup failed
Expected: Found certificate for subject "CN=Test CA"
Actual: null (certificate not found)

The certificate exists in the trust store but cannot be found by subject.
at android.security.net.cts.NetworkSecurityConfigTest.testCertificateFindBySubject(NetworkSecurityConfigTest.java:156)
```

## 現象描述
CTS 測試報告根據 subject 查找憑證時返回 null，
即使憑證確實存在於信任存儲中。

## 提示
- Subject 是 X.509 憑證的主體名稱
- 查找通常使用 X500Principal 進行比較
- 問題可能在於比較邏輯

## 選項

A) `findBySubject()` 中使用 `==` 比較 X500Principal 而非 `equals()`

B) `findBySubject()` 中將 subject 和 issuer 混淆了

C) `findBySubject()` 使用了大小寫敏感的字串比較

D) `findBySubject()` 在找到結果後沒有返回，繼續迴圈直到結束
