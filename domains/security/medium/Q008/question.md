# Q008: Verified Boot State Parsing

## CTS Test
`android.keystore.cts.RootOfTrustTest#testVerifiedBootState`

## Failure Log
```
junit.framework.AssertionFailedError: 
Verified boot state mismatch
Expected: VERIFIED (green)
Actual: UNVERIFIED (orange)
Device passed AVB verification but reports wrong state

at android.keystore.cts.RootOfTrustTest.testVerifiedBootState(RootOfTrustTest.java:89)
```

## 現象描述
CTS 測試報告 Verified Boot 狀態不正確。設備通過了 AVB 驗證（綠色啟動），
但信任根報告為未驗證（橙色啟動）。

## 提示
- Verified Boot 狀態：VERIFIED=0, SELF_SIGNED=1, UNVERIFIED=2, FAILED=3
- 狀態值從 ASN.1 整數解析
- 問題出在狀態值對應邏輯

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// RootOfTrust.java
public enum VerifiedBootState {
    VERIFIED,      // 0 - Green: Boot chain is verified
    SELF_SIGNED,   // 1 - Yellow: Custom key
    UNVERIFIED,    // 2 - Orange: Unlocked bootloader
    FAILED         // 3 - Red: Verification failed
}

public VerifiedBootState parseBootState(int value) {
    VerifiedBootState[] states = VerifiedBootState.values();
    if (value < 0 || value > states.length) {  // LINE A
        return VerifiedBootState.UNVERIFIED;
    }
    return states[value];
}
```

A) 應該使用 switch-case 而非陣列索引
B) LINE A 的條件應該是 `value >= states.length`（不是 >）
C) 枚舉順序與數值不一致
D) 預設返回值應該是 FAILED 而非 UNVERIFIED
