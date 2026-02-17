# Q006: No Auth Required Flag

## CTS Test
`android.keystore.cts.AuthorizationListTest#testNoAuthRequired`

## Failure Log
```
junit.framework.AssertionFailedError: 
noAuthRequired flag mismatch
Expected: true (key should be usable without authentication)
Actual: false
Key requires authentication when it shouldn't

at android.keystore.cts.AuthorizationListTest.testNoAuthRequired(AuthorizationListTest.java:178)
```

## 現象描述
CTS 測試報告 noAuthRequired 標記解析錯誤。密鑰生成時設定為不需要用戶認證，
但授權列表顯示需要認證。

## 提示
- noAuthRequired 是一個布林標籤
- TAG 的存在本身就代表 true
- 問題出在標籤存在性檢查

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// AuthorizationList.java
private static final int TAG_NO_AUTH_REQUIRED = 503;

public boolean isNoAuthRequired() {
    ASN1Primitive tag = findTag(TAG_NO_AUTH_REQUIRED);
    if (tag == null) {
        return true;  // LINE A
    }
    return false;  // LINE B
}
```

A) TAG_NO_AUTH_REQUIRED 常數值錯誤
B) LINE A 和 LINE B 的返回值應該對調
C) 應該解析 tag 的內容而非僅檢查存在性
D) 應該拋出異常當 tag 為 null 時
