# SEC-E005: Padding Mode 驗證錯誤

## CTS Test
`android.keystore.cts.AuthorizationListTest#testPaddingPkcs1`

## Failure Log
```
junit.framework.AssertionFailedError: PKCS1 padding not recognized
Expected: KM_PAD_RSA_PKCS1_1_5_ENCRYPT in padding list
Actual: Empty padding list

at android.keystore.cts.AuthorizationListTest.testPaddingPkcs1(AuthorizationListTest.java:178)
```

## 現象描述
CTS 測試報告使用 PKCS1 填充模式的 RSA 密鑰，
其 AuthorizationList 中的 padding 列表為空，
導致無法正確識別填充模式。

## 提示
- Padding 是加密時的填充方式
- 常見 RSA padding：NONE, PKCS1_1_5_ENCRYPT, PKCS1_1_5_SIGN, OAEP, PSS
- 問題可能在於解析 padding 時的處理邏輯

## 選項

A) 解析 padding TAG 時將值加入了錯誤的列表

B) 解析 padding 時直接跳過不處理（missing break 後的邏輯）

C) `getPaddings()` 返回了新建的空列表而非成員變數

D) Padding 常數值定義與 KeyMaster 規格不一致
