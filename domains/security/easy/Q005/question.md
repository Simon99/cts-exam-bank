# Q005: Padding Mode Validation

## CTS Test
`android.keystore.cts.AuthorizationListTest#testPadding`

## Failure Log
```
junit.framework.AssertionFailedError: 
Padding mode mismatch
Expected padding modes: [PKCS7]
Actual padding modes: [NONE, PKCS7, RSA_OAEP]
Authorization list includes unsupported padding modes

at android.keystore.cts.AuthorizationListTest.testPadding(AuthorizationListTest.java:145)
```

## 現象描述
CTS 測試報告授權列表中包含了不應該存在的填充模式。
密鑰生成時只指定了 PKCS7，但授權列表卻顯示包含多種填充模式。

## 提示
- 填充模式列表應該只包含生成時指定的模式
- 問題出在列表初始化或清除邏輯
- 檢查是否有預設值被錯誤保留

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
private Set<Integer> paddingModes = new HashSet<>(
    Arrays.asList(PADDING_NONE, PADDING_PKCS7, PADDING_RSA_OAEP)
);

public void parsePaddingModes(ASN1Sequence sequence) {
    // paddingModes.clear();  // LINE A - 被註解掉了
    for (int i = 0; i < sequence.size(); i++) {
        ASN1Integer padding = (ASN1Integer) sequence.getObjectAt(i);
        paddingModes.add(padding.intValueExact());  // LINE B
    }
}

public Set<Integer> getPaddingModes() {
    return paddingModes;
}
```

A) LINE B 應該使用 put() 而非 add()
B) HashSet 應該改用 ArrayList
C) LINE A 應該取消註解，清除預設值
D) getPaddingModes() 應該返回副本
