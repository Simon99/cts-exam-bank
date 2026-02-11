# Q003: Attestation Challenge Verification

## CTS Test
`android.keystore.cts.AttestationTest#testAttestationChallenge`

## Failure Log
```
junit.framework.AssertionFailedError: 
Attestation challenge mismatch
Expected challenge: [16 bytes of challenge data]
Actual challenge: [different data or wrong length]
Challenge in attestation doesn't match the one provided during key generation

at android.keystore.cts.AttestationTest.testAttestationChallenge(AttestationTest.java:198)
```

## 現象描述
CTS 測試報告認證挑戰值不匹配。生成密鑰時提供的挑戰值與認證中記錄的不一致。

## 提示
- 挑戰值應該完全匹配（長度和內容）
- 問題可能出在長度計算或比較邏輯
- 注意陣列比較的方式

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// Attestation.java
public boolean verifyChallenge(byte[] expectedChallenge) {
    if (expectedChallenge == null || this.attestationChallenge == null) {
        return false;
    }
    
    if (expectedChallenge.length != this.attestationChallenge.length) {
        return false;
    }
    
    // Compare challenge bytes
    for (int i = 0; i < expectedChallenge.length - 1; i++) {  // LINE A
        if (expectedChallenge[i] != this.attestationChallenge[i]) {
            return false;
        }
    }
    return true;
}
```

A) 應該使用 Arrays.equals() 而非手動比較
B) LINE A 的迴圈應該是 `i < expectedChallenge.length`（不是 length - 1）
C) null 檢查應該在長度比較之後
D) 應該使用 MessageDigest 比較雜湊值而非直接比較
