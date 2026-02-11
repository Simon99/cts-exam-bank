# SEC-E010: Attestation Version 返回錯誤值

## CTS Test
`android.keystore.cts.AttestationTest#testAttestationVersion`

## Failure Log
```
junit.framework.AssertionFailedError: Wrong attestation version
Expected: >= 3 (KeyMint attestation)
Actual: 0

at android.keystore.cts.AttestationTest.testAttestationVersion(AttestationTest.java:112)
```

## 現象描述
CTS 測試報告 Attestation 版本為 0，
但現代設備應該支援 KeyMint，版本至少為 3。

## 提示
- Attestation 版本對應 KeyMaster/KeyMint 版本
- 版本 1-2: KeyMaster, 版本 3+: KeyMint
- 問題可能在於版本欄位的返回

## 選項

A) `getAttestationVersion()` 返回了 `keymasterVersion` 而非 `attestationVersion`

B) `getAttestationVersion()` 硬編碼返回 0

C) 版本解析時使用了錯誤的 byte 順序

D) `getAttestationVersion()` 返回了版本的負值
