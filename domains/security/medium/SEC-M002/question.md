# SEC-M002: Attestation Challenge 驗證長度錯誤

## CTS Test
`android.keystore.cts.AttestationTest#testAttestationChallenge`

## Failure Log
```
junit.framework.AssertionFailedError: Attestation challenge mismatch
Expected: challenge.length == 32
Actual: challenge.length == 64 (challenge repeated twice)

at android.keystore.cts.AttestationTest.testAttestationChallenge(AttestationTest.java:198)
```

## 現象描述
CTS 測試報告 Attestation Challenge 的長度是預期的兩倍。
原本設定的 32 位元組挑戰值變成了 64 位元組，
看起來像是原始值被複製了兩次。

## 提示
- Attestation Challenge 是客戶端提供的隨機值
- 用於防止重放攻擊
- 問題可能在於解析時的緩衝區操作

## 選項

A) `parseChallenge()` 中的迴圈條件使用 `<=` 而非 `<`，多讀了一輪

B) `parseChallenge()` 中意外調用了兩次 `read()`，把 challenge 讀了兩遍

C) `parseChallenge()` 中的緩衝區大小設為 `length * 2` 而非 `length`

D) `getAttestationChallenge()` 返回了 `ByteBuffer.duplicate()` 而重複了內容
