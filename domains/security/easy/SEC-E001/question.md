# SEC-E001: Attestation 擴展格式檢查錯誤

## CTS Test
`android.keystore.cts.AttestationTest#testEatExtensionParsing`

## Failure Log
```
junit.framework.AssertionFailedError: Wrong attestation extension format detected
Expected: EAT extension present
Actual: Incorrectly reports ASN1 format

at android.keystore.cts.AttestationTest.testEatExtensionParsing(AttestationTest.java:156)
```

## 現象描述
CTS 測試報告在解析 Key Attestation 憑證時，錯誤地將 EAT (Entity Attestation Token) 格式識別為 ASN1 格式。
這導致認證擴展解析失敗。

## 提示
- Attestation 憑證可能包含 EAT 或傳統 ASN1 格式的擴展
- 檢查順序很重要：應先檢查 EAT，再 fallback 到 ASN1
- 問題可能在於條件判斷邏輯

## 選項

A) `loadFromCertificate()` 中將 EAT 和 ASN1 的檢查順序顛倒了

B) `loadFromCertificate()` 中使用 `||` 而非 `&&` 連接 EAT 檢查條件

C) `loadFromCertificate()` 中將 `eatExtension != null` 錯寫為 `eatExtension == null`

D) `loadFromCertificate()` 中缺少 EAT 擴展 OID 的定義
