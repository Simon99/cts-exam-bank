# Q007: User Auth Type Parsing

## CTS Test
`android.keystore.cts.AuthorizationListTest#testUserAuthType`

## Failure Log
```
junit.framework.AssertionFailedError: 
User authentication type mismatch
Expected: BIOMETRIC only
Actual: PASSWORD | BIOMETRIC (both flags set)
Key should only require biometric authentication

at android.keystore.cts.AuthorizationListTest.testUserAuthType(AuthorizationListTest.java:167)
```

## 現象描述
CTS 測試報告用戶認證類型不正確。密鑰只設定了生物識別認證要求，
但授權列表顯示還包含了密碼認證類型。

## 提示
- 認證類型是位元標誌組合
- PASSWORD = 1, BIOMETRIC = 2
- 問題出在標誌解析或計算

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
public static final int AUTH_TYPE_PASSWORD = 1;
public static final int AUTH_TYPE_BIOMETRIC = 2;

private int userAuthType = AUTH_TYPE_PASSWORD;  // LINE A - default value

public void parseUserAuthType(ASN1Integer value) {
    userAuthType = userAuthType | value.intValueExact();  // LINE B
}

public boolean requiresPassword() {
    return (userAuthType & AUTH_TYPE_PASSWORD) != 0;
}

public boolean requiresBiometric() {
    return (userAuthType & AUTH_TYPE_BIOMETRIC) != 0;
}
```

A) AUTH_TYPE 常數值定義錯誤
B) LINE A 的預設值應該是 0
C) LINE B 應該使用賦值 `=` 而非 OR `|=`
D) 選項 B 和 C 都需要修正
