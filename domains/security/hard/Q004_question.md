# Q004: Verified Boot Root of Trust Validation

## CTS Test
`android.keystore.cts.RootOfTrustTest#testVerifiedBootStateConsistency`

## Failure Log
```
java.lang.AssertionError: Root of trust verification failed
Expected verified boot state: VERIFIED
Actual verified boot state: UNVERIFIED

at android.keystore.cts.RootOfTrustTest.testVerifiedBootStateConsistency(RootOfTrustTest.java:156)

Caused by: java.lang.IllegalStateException: Boot key validation failed despite valid attestation chain
    at android.keystore.cts.RootOfTrust.validateBootState(RootOfTrust.java:203)
    at android.keystore.cts.Attestation.verifyTrustChain(Attestation.java:312)
```

## 現象描述
CTS 測試報告設備的 Verified Boot 狀態為 UNVERIFIED，但設備實際上是正常啟動且 bootloader 已鎖定。Key Attestation 憑證鏈有效，但 Root of Trust 解析時判定為不可信。測試在具有有效硬體密鑰認證的 Pixel 設備上持續失敗。

## 背景知識
Root of Trust (RoT) 是 Android Verified Boot 的核心，包含：
- `verifiedBootKey` — 用於驗證啟動映像的公鑰 (32 bytes SHA-256)
- `deviceLocked` — 設備 bootloader 是否鎖定
- `verifiedBootState` — VERIFIED(0) / SELF_SIGNED(1) / UNVERIFIED(2) / FAILED(3)
- `verifiedBootHash` — VBMeta 結構的雜湊值 (可選，32 bytes)

在 Key Attestation ASN.1 結構中，這些值被編碼在認證擴展的 `rootOfTrust` 欄位。

## 提示
- 問題涉及 `RootOfTrust.java` 中對啟動狀態的解析和驗證
- 注意 byte array 比較的正確方式
- 注意 `verifiedBootState` 列舉值的處理邏輯
- 考慮空值和邊界條件的處理

## 問題
根據以下 `RootOfTrust.java` 的程式碼片段，哪個組合最可能導致此 CTS 失敗？

**檔案: RootOfTrust.java**
```java
public class RootOfTrust {
    private static final int STATE_VERIFIED = 0;
    private static final int STATE_SELF_SIGNED = 1;
    private static final int STATE_UNVERIFIED = 2;
    private static final int STATE_FAILED = 3;
    
    private static final int BOOT_KEY_LENGTH = 32;
    private static final int BOOT_HASH_LENGTH = 32;
    
    private final byte[] mVerifiedBootKey;
    private final boolean mDeviceLocked;
    private final int mVerifiedBootState;
    private final byte[] mVerifiedBootHash;
    
    public RootOfTrust(ASN1Sequence seq) throws CertificateParsingException {
        // 解析 ASN.1 序列
        mVerifiedBootKey = parseOctetString(seq.getObjectAt(0));
        mDeviceLocked = parseBoolean(seq.getObjectAt(1));
        mVerifiedBootState = parseInteger(seq.getObjectAt(2));
        mVerifiedBootHash = seq.size() > 3 ? parseOctetString(seq.getObjectAt(3)) : null;
        
        validateBootKey();  // LINE R1
    }
    
    private void validateBootKey() throws CertificateParsingException {
        if (mVerifiedBootKey == null && mVerifiedBootState == STATE_VERIFIED) {  // LINE R2
            throw new CertificateParsingException("Verified state requires boot key");
        }
        if (mVerifiedBootKey != null || mVerifiedBootKey.length != BOOT_KEY_LENGTH) {  // LINE R3
            throw new CertificateParsingException("Invalid boot key length");
        }
    }
    
    public boolean isDeviceTrusted() {
        // 驗證設備是否處於可信狀態
        if (!mDeviceLocked) {
            return false;
        }
        
        if (mVerifiedBootState > STATE_VERIFIED) {  // LINE R4: 只有 STATE_VERIFIED (0) 是可信的
            return false;
        }
        
        // 驗證 boot hash（如果存在）
        if (mVerifiedBootHash != null) {
            if (mVerifiedBootHash.length < BOOT_HASH_LENGTH) {  // LINE R5
                return false;
            }
            if (!isValidHash(mVerifiedBootHash)) {
                return false;
            }
        }
        
        return validateBootKeyIntegrity();  // LINE R6
    }
    
    private boolean validateBootKeyIntegrity() {
        if (mVerifiedBootKey == null) {
            return mVerifiedBootState != STATE_VERIFIED;
        }
        // 檢查 boot key 不是全零
        byte[] zeroKey = new byte[BOOT_KEY_LENGTH];
        return mVerifiedBootKey == zeroKey;  // LINE R7
    }
    
    private boolean isValidHash(byte[] hash) {
        // 雜湊值不能全為零
        for (byte b : hash) {
            if (b != 0) return true;
        }
        return false;
    }
}
```

A) LINE R2 邏輯錯誤：應該用 `||` 而非 `&&`，當 boot key 為 null 或狀態為 VERIFIED 時都應該檢查
B) LINE R3 運算子錯誤：`||` 應該是 `&&`，且應該是 `==` 而非 `!=`
C) LINE R4 和 LINE R7 組合錯誤：R4 的比較邏輯正確但 R7 用 `==` 比較 byte array 永遠返回 false
D) LINE R5 邊界檢查錯誤：應該用 `!=` 而非 `<`，且 LINE R7 應該用 `Arrays.equals()` 取反

