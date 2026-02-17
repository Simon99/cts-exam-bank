# Q005: Key Attestation 挑戰值驗證失敗

## CTS Test
`android.keystore.cts.AttestationTest#testAttestationChallengeVerification`

## Failure Log
```
java.lang.AssertionError: Attestation challenge verification failed

Test: Generate key with attestation and verify challenge

Key generation parameters:
  Algorithm: EC P-256
  Attestation challenge: [16 bytes] "CTS_TEST_1234567"
  
Attestation certificate retrieved successfully.
Parsing attestation extension (OID 1.3.6.1.4.1.11129.2.1.17)...

Parsed attestation data:
  attestationVersion:     3
  attestationSecurityLevel: TEE
  keymasterVersion:       200
  keymasterSecurityLevel: TEE
  attestationChallenge:   [16 bytes] "CTS_TEST_1234567"
  
Challenge verification:
  Expected challenge: [67, 84, 83, 95, 84, 69, 83, 84, 95, 49, 50, 51, 52, 53, 54, 55]
  Actual challenge:   [67, 84, 83, 95, 84, 69, 83, 84, 95, 49, 50, 51, 52, 53, 54, 55]
  
  Verification method: Attestation.verifyChallenge(expectedChallenge)
  
  Debug trace:
    > verifyChallenge() called
    > mChallenge.length = 16, expected.length = 16
    > Length check: PASS
    > Content comparison started
    > Using constant-time comparison for security
    > diff accumulator after loop: 0
    > Return value: false  <-- UNEXPECTED
    
Expected: Challenge matches -> return true
Actual:   Challenge matches but verification returns false

at android.keystore.cts.AttestationTest.testAttestationChallengeVerification(AttestationTest.java:312)
```

## 現象描述
CTS 測試中 Key Attestation 的挑戰值驗證失敗。日誌顯示所有位元組完全匹配（diff = 0），但 `verifyChallenge()` 仍返回 `false`。

## 背景知識
Key Attestation 允許應用驗證金鑰是否在安全環境（TEE/StrongBox）中生成。attestationChallenge 是呼叫方提供的隨機值，用於防止重放攻擊。驗證時必須確保回傳的 challenge 與傳入的完全相同。

為了防止 timing attack，安全相關的比較通常使用 constant-time 演算法：無論哪個位置不匹配，都要完整比較所有位元組，並用 XOR 累積差異。

## 提示
- 仔細觀察 constant-time 比較的實作
- 注意 `diff` 的累積方式和最終判斷邏輯
- 考慮位元運算的返回值類型

## 程式碼片段

**Attestation.java:**
```java
public class Attestation {
    private byte[] mChallenge;
    
    /**
     * Verifies the attestation challenge matches the expected value.
     * Uses constant-time comparison to prevent timing attacks.
     *
     * @param expected The expected challenge bytes
     * @return true if challenges match, false otherwise
     */
    public boolean verifyChallenge(byte[] expected) {
        if (expected == null || mChallenge == null) {
            return false;
        }
        
        if (expected.length != mChallenge.length) {
            return false;
        }
        
        // Constant-time comparison to prevent timing attacks
        int diff = 0;
        for (int i = 0; i < mChallenge.length; i++) {
            diff |= mChallenge[i] ^ expected[i];
        }
        
        // Return true if no differences found
        return diff == 0 ? false : true;
    }
}
```

## 選項

A) XOR 運算 `mChallenge[i] ^ expected[i]` 對於 byte 類型會產生負數，當 `diff` 累積這些負數後，即使匹配也不會是 0

B) 返回條件寫反了：`diff == 0 ? false : true` 應該是 `diff == 0 ? true : false`，或直接寫 `return diff == 0`

C) `|=` 運算會將 byte 提升為 int 並保留符號，導致 diff 可能累積到負數，使 `diff == 0` 判斷失敗

D) 應該使用 `&=` 而非 `|=` 來累積差異，因為只有當所有 XOR 結果都為 0 時才表示完全匹配
