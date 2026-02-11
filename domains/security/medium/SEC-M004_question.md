# SEC-M004: Digest 列表解析使用錯誤的 TAG

## CTS Test
`android.keystore.cts.AuthorizationListTest#testDigestSha256`

## Failure Log
```
junit.framework.AssertionFailedError: Digest list incorrect
Expected: KM_DIGEST_SHA_2_256 (4) present
Actual: Digest list contains wrong values [1, 2, 3]

at android.keystore.cts.AuthorizationListTest.testDigestSha256(AuthorizationListTest.java:267)
```

## 現象描述
CTS 測試報告 Digest 列表包含錯誤的值。
預期應該包含 SHA256 的常數值，但實際包含的是 Purpose 的值。
這表示解析時使用了錯誤的 TAG。

## 提示
- Digest 和 Purpose 都是多值 TAG
- Digest TAG 值與 Purpose TAG 值不同
- 問題可能在於 TAG 常數的使用

## 選項

A) 解析 Digest 時使用了 `KM_TAG_PURPOSE` 而非 `KM_TAG_DIGEST`

B) Digest 常數值定義與 KeyMaster 規格不一致

C) 解析 Digest 時將值加入了 Purpose 列表

D) getDigests() 返回了 getPurposes() 的結果
