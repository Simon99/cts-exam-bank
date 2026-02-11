# SEC-M003: AuthorizationList Purpose 驗證邏輯錯誤

## CTS Test
`android.keystore.cts.AuthorizationListTest#testPurposeEncryptDecrypt`

## Failure Log
```
junit.framework.AssertionFailedError: Key purpose validation failed
Expected: PURPOSE_ENCRYPT and PURPOSE_DECRYPT both present
Actual: Only PURPOSE_ENCRYPT found

Test key was generated with both purposes but only one is parsed.
at android.keystore.cts.AuthorizationListTest.testPurposeEncryptDecrypt(AuthorizationListTest.java:234)
```

## 現象描述
當密鑰同時擁有加密和解密用途時，解析 AuthorizationList 只找到加密用途。
這表示多重用途的解析邏輯有問題。

## 提示
- Purpose 是一個可以有多個值的標籤
- 常見用途：ENCRYPT(0), DECRYPT(1), SIGN(2), VERIFY(3)
- 問題可能在於多值處理的迴圈邏輯

## 選項

A) 解析 Purpose TAG 時在找到第一個值後就 break 了

B) `getPurposes()` 返回了只包含第一個元素的新列表

C) 解析 Purpose 時使用 `=` 而非 `+=` 累加

D) Purpose 列表在每次解析前被錯誤地清空
