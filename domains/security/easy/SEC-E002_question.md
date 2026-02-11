# SEC-E002: Security Level 解析返回錯誤值

## CTS Test
`android.keystore.cts.AttestationTest#testSecurityLevel`

## Failure Log
```
junit.framework.AssertionFailedError: Wrong security level
Expected: KM_SECURITY_LEVEL_TRUSTED_ENVIRONMENT (1)
Actual: KM_SECURITY_LEVEL_SOFTWARE (0)

at android.keystore.cts.AttestationTest.testSecurityLevel(AttestationTest.java:203)
```

## 現象描述
CTS 測試報告 Key Attestation 的安全等級解析錯誤。
即使密鑰儲存在 TEE (Trusted Execution Environment) 中，
`getSecurityLevel()` 仍然返回 SOFTWARE 等級。

## 提示
- Security Level 有三個值：SOFTWARE(0), TRUSTED_ENVIRONMENT(1), STRONGBOX(2)
- 問題可能在於常數值的使用
- 檢查 getter 方法的返回邏輯

## 選項

A) `getSecurityLevel()` 方法中返回了 `attestationSecurityLevel` 而非 `keymasterSecurityLevel`

B) `getSecurityLevel()` 方法中硬編碼返回 `KM_SECURITY_LEVEL_SOFTWARE`

C) `getSecurityLevel()` 方法中將 TEE 等級錯誤映射為 SOFTWARE

D) Security Level 常數定義中 TEE 和 SOFTWARE 的值互換了
