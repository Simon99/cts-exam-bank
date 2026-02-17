# Q004: Key Size Validation

## CTS Test
`android.keystore.cts.AuthorizationListTest#testKeySize`

## Failure Log
```
junit.framework.AssertionFailedError: 
Key size validation failed
Expected: 256 bits (EC P-256)
Actual: 0 bits
Authorization list reports zero key size

at android.keystore.cts.AuthorizationListTest.testKeySize(AuthorizationListTest.java:112)
```

## 現象描述
CTS 測試報告密鑰大小為 0。使用 P-256 曲線生成的 EC 密鑰應該報告 256 bits，
但授權列表解析後顯示為 0。

## 提示
- 密鑰大小從 TAG_KEY_SIZE 標籤解析
- ASN.1 整數可能需要特殊處理
- 問題出在數值解析邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
private Integer parseKeySize(ASN1Primitive primitive) {
    if (primitive instanceof ASN1Integer) {
        ASN1Integer asn1Int = (ASN1Integer) primitive;
        int value = asn1Int.intValueExact();
        return value;  // LINE A
    }
    return 0;  // LINE B
}

public Integer getKeySize() {
    ASN1Primitive keySizeTag = findTag(TAG_KEY_SIZE);
    if (keySizeTag == null) {
        return null;
    }
    return parseKeySize(keySizeTag);  // LINE C
}
```

A) LINE A 應該返回 Integer.valueOf(value)
B) LINE B 應該返回 null 而非 0
C) LINE C 傳入的是 TAG 本身而非 TAG 的值
D) intValueExact() 應該改用 getValue()
