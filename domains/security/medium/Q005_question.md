# Q005: Key Purpose Validation

## CTS Test
`android.keystore.cts.AuthorizationListTest#testPurpose`

## Failure Log
```
junit.framework.AssertionFailedError: 
Purpose validation failed
Key generated with SIGN purpose should not allow ENCRYPT
Expected purposes: [SIGN]
Actual purposes: [SIGN, ENCRYPT, DECRYPT]

at android.keystore.cts.AuthorizationListTest.testPurpose(AuthorizationListTest.java:95)
```

## 現象描述
CTS 測試報告密鑰用途驗證失敗。密鑰只應該有 SIGN 用途，
但授權列表顯示還包含了 ENCRYPT 和 DECRYPT。

## 提示
- 用途是可重複的枚舉類型（ENUM_REP）
- 每個密鑰生成時指定允許的用途
- 問題出在用途的累加邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
private static final Set<Integer> DEFAULT_PURPOSES = new HashSet<>(
    Arrays.asList(PURPOSE_ENCRYPT, PURPOSE_DECRYPT)
);

private Set<Integer> purposes = new HashSet<>(DEFAULT_PURPOSES);

public void parsePurposes(ASN1Sequence sequence) {
    for (int i = 0; i < sequence.size(); i++) {
        ASN1Integer purposeValue = (ASN1Integer) sequence.getObjectAt(i);
        purposes.add(purposeValue.intValueExact());  // LINE A
    }
}

public Set<Integer> getPurposes() {
    return Collections.unmodifiableSet(purposes);
}
```

A) LINE A 應該使用 put() 而非 add()
B) 應該在解析前清除 purposes 集合
C) DEFAULT_PURPOSES 應該是空集合
D) 應該使用 EnumSet 而非 HashSet
