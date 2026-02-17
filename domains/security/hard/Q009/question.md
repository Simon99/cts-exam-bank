# Q009: Root of Trust Attestation Version Handling

## CTS Test
`android.keystore.cts.KeyAttestationTest#testRootOfTrustAttestation`

## Failure Log
```
java.lang.AssertionError: verifiedBootHash should not be null for attestation version >= 3
Expected: not null
     but: was null

at org.hamcrest.MatcherAssert.assertThat(MatcherAssert.java:20)
at android.keystore.cts.KeyAttestationTest.checkRootOfTrust(KeyAttestationTest.java:1247)
at android.keystore.cts.KeyAttestationTest.testRootOfTrustAttestation(KeyAttestationTest.java:892)

Additional info:
  attestationVersion: 100
  keymasterVersion: 100
  verifiedBootState: VERIFIED (0)
  verifiedBootKey: [32 bytes present]
  verifiedBootHash: null
```

## 現象描述
在 KeyMint 1.0 (attestationVersion=100) 設備上執行 Root of Trust 認證測試失敗。測試期望 `verifiedBootHash` 存在，但解析結果為 null。設備狀態正常（Verified Boot 狀態為 VERIFIED），且 `verifiedBootKey` 正確存在。

## 背景知識
- **Root of Trust** 是 Key Attestation 的核心組成，包含啟動驗證資訊
- **attestationVersion** 代表認證擴展的版本（1, 2, 3, 4, 100, 200, 300...）
- **verifiedBootHash** 從 attestationVersion 3 開始引入
- KeyMint 版本使用 100 為基數（KeyMint 1.0 = 100, 2.0 = 200, 3.0 = 300）
- KeyMaster 版本使用 10 為基數（KeyMaster 3.0 = 30, 4.0 = 40）

## 提示
- 問題涉及 `RootOfTrust.java` 和 `KeyAttestationTest.java` 兩個檔案
- 注意 attestationVersion 的數值範圍與版本判斷邏輯
- KeyMint 和 KeyMaster 使用不同的版本編號體系

## 問題
根據以下兩個檔案的程式碼片段，哪個組合最可能導致此 CTS 失敗？

**檔案 1: RootOfTrust.java**
```java
public class RootOfTrust {
    private static final int VERIFIED_BOOT_KEY_INDEX = 0;
    private static final int DEVICE_LOCKED_INDEX = 1;
    private static final int VERIFIED_BOOT_STATE_INDEX = 2;
    private static final int VERIFIED_BOOT_HASH_INDEX = 3;

    private final byte[] mVerifiedBootKey;
    private final boolean mDeviceLocked;
    private final int mVerifiedBootState;
    private final byte[] mVerifiedBootHash;

    public RootOfTrust(ASN1Encodable asn1Encodable, int attestationVersion)
            throws CertificateParsingException {
        if (!(asn1Encodable instanceof ASN1Sequence)) {
            throw new CertificateParsingException("Expected sequence");
        }

        ASN1Sequence sequence = (ASN1Sequence) asn1Encodable;
        mVerifiedBootKey = Asn1Utils.getByteArrayFromAsn1(
            sequence.getObjectAt(VERIFIED_BOOT_KEY_INDEX));
        mDeviceLocked = Asn1Utils.getBooleanFromAsn1(
            sequence.getObjectAt(DEVICE_LOCKED_INDEX));
        mVerifiedBootState = Asn1Utils.getIntegerFromAsn1(
            sequence.getObjectAt(VERIFIED_BOOT_STATE_INDEX));
        
        // verifiedBootHash 從 attestation version 3 開始引入
        if (attestationVersion >= 3 && attestationVersion < 100) {  // LINE R1
            mVerifiedBootHash = Asn1Utils.getByteArrayFromAsn1(
                sequence.getObjectAt(VERIFIED_BOOT_HASH_INDEX));
        } else {
            mVerifiedBootHash = null;
        }
    }
    
    public byte[] getVerifiedBootHash() {
        return mVerifiedBootHash;
    }
}
```

**檔案 2: KeyAttestationTest.java（驗證邏輯）**
```java
private void checkRootOfTrust(Attestation attestation, boolean requireLocked) {
    RootOfTrust rootOfTrust = attestation.getRootOfTrust();
    assertNotNull("Root of trust must be present", rootOfTrust);
    
    int attestationVersion = attestation.getAttestationVersion();
    
    // 驗證 verifiedBootKey
    assertNotNull("verifiedBootKey should not be null", 
                  rootOfTrust.getVerifiedBootKey());
    
    // 驗證 verifiedBootHash（v3+ 必須存在）
    if (attestationVersion > 3) {  // LINE T1
        assertNotNull("verifiedBootHash should not be null for attestation version >= 3",
                      rootOfTrust.getVerifiedBootHash());
    }
    
    // 驗證 verifiedBootState
    int bootState = rootOfTrust.getVerifiedBootState();
    assertTrue("Invalid boot state: " + bootState,
               bootState >= RootOfTrust.KM_VERIFIED_BOOT_VERIFIED &&
               bootState <= RootOfTrust.KM_VERIFIED_BOOT_FAILED);  // LINE T2
}
```

A) LINE R1 條件錯誤：`attestationVersion < 100` 排除了所有 KeyMint 版本，應該移除此限制
B) LINE T1 條件錯誤：`attestationVersion > 3` 應該是 `attestationVersion >= 3`
C) 問題出在 LINE R1 和 LINE T1 的組合：R1 排除 KeyMint，T1 又使用錯誤的比較運算子
D) LINE T2 邊界檢查錯誤：應該是 `bootState > RootOfTrust.KM_VERIFIED_BOOT_VERIFIED`

