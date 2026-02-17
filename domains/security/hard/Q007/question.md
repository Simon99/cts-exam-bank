# Q007: RootOfTrust Verified Boot State Validation

## CTS Test
`android.keystore.cts.AttestationTest#testRootOfTrustVerification`

## Failure Log
```
junit.framework.AssertionFailedError: Root of trust verification failed
Expected verified boot state: VERIFIED
Actual verified boot state validation passed incorrectly for UNVERIFIED device

at android.keystore.cts.AttestationTest.testRootOfTrustVerification(AttestationTest.java:412)
at android.keystore.cts.RootOfTrust.validate(RootOfTrust.java:156)

Caused by: java.lang.SecurityException: RootOfTrust validation inconsistent
    verifiedBootKey hash mismatch ignored
    verifiedBootState: 0 (should reject but passed)
```

## 現象描述
CTS 測試報告 Root of Trust 驗證邏輯異常。在設備處於 UNVERIFIED 狀態時（verifiedBootState = 0），系統應該拒絕認證請求或標記為不安全，但測試卻通過了驗證。同時，verifiedBootKey 的雜湊比對失敗也被忽略。

## 背景知識
Android Verified Boot (AVB) 透過 RootOfTrust 結構記錄啟動驗證狀態：
- `verifiedBootKey`: 用於驗證啟動映像的公鑰（32 bytes SHA-256）
- `deviceLocked`: 設備是否已鎖定 bootloader
- `verifiedBootState`: 啟動驗證狀態
  - 0 = UNVERIFIED（未驗證，不安全）
  - 1 = SELF_SIGNED（自簽名）
  - 2 = VERIFIED（完全驗證）
- `verifiedBootHash`: 所有啟動分區的組合雜湊

在 Key Attestation 中，RootOfTrust 的驗證結果會影響憑證的可信度。

## 提示
- 問題涉及 `RootOfTrust.java` 的驗證邏輯
- 注意多個驗證條件如何組合
- 注意 `verifiedBootState` 的數值判斷方式
- 思考驗證邏輯的短路評估行為

## 問題
根據以下程式碼片段，分析 RootOfTrust 驗證邏輯中的問題：

**檔案: RootOfTrust.java**
```java
public class RootOfTrust {
    private final byte[] mVerifiedBootKey;      // 32 bytes
    private final boolean mDeviceLocked;
    private final int mVerifiedBootState;       // 0=UNVERIFIED, 1=SELF_SIGNED, 2=VERIFIED
    private final byte[] mVerifiedBootHash;     // 32 bytes
    
    public static final int VERIFIED_BOOT_STATE_UNVERIFIED = 0;
    public static final int VERIFIED_BOOT_STATE_SELF_SIGNED = 1;
    public static final int VERIFIED_BOOT_STATE_VERIFIED = 2;
    
    // 預期的可信啟動密鑰雜湊（由 OEM 設定）
    private static final byte[] TRUSTED_BOOT_KEY_HASH = getTrustedBootKeyHash();
    
    public ValidationResult validate(byte[] expectedBootHash) {
        // 檢查 1: 驗證啟動密鑰
        boolean keyValid = validateBootKey();  // LINE R1
        
        // 檢查 2: 驗證啟動狀態
        boolean stateValid = validateBootState();  // LINE R2
        
        // 檢查 3: 驗證啟動雜湊
        boolean hashValid = validateBootHash(expectedBootHash);  // LINE R3
        
        // 組合驗證結果
        if (keyValid || stateValid || hashValid) {  // LINE R4
            return ValidationResult.success();
        }
        return ValidationResult.failure("RootOfTrust validation failed");
    }
    
    private boolean validateBootKey() {
        if (mVerifiedBootKey == null || mVerifiedBootKey.length != 32) {
            return false;
        }
        return MessageDigest.isEqual(
            sha256(mVerifiedBootKey), 
            TRUSTED_BOOT_KEY_HASH
        );
    }
    
    private boolean validateBootState() {
        // 只有 VERIFIED 狀態才是完全可信的
        if (mVerifiedBootState > VERIFIED_BOOT_STATE_UNVERIFIED) {  // LINE R5
            return true;
        }
        return mDeviceLocked;  // LINE R6
    }
    
    private boolean validateBootHash(byte[] expected) {
        if (expected == null && mVerifiedBootHash == null) {  // LINE R7
            return true;
        }
        if (expected == null || mVerifiedBootHash == null) {
            return false;
        }
        return Arrays.equals(mVerifiedBootHash, expected);  // LINE R8
    }
}
```

哪個選項最準確地描述了導致 CTS 失敗的 bug 組合？

A) LINE R5 邏輯錯誤：`>` 應該是 `>=`，導致 UNVERIFIED (0) 狀態被錯誤拒絕
B) LINE R4 邏輯錯誤：使用 `||`（OR）而非 `&&`（AND），任一條件通過就算驗證成功
C) LINE R6 和 R7 的組合：當 deviceLocked=true 或 expected=null 時會繞過嚴格驗證
D) LINE R5 和 R4 的組合：SELF_SIGNED (1) 錯誤通過 + OR 邏輯導致整體驗證通過

