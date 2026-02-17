# SEC-M006: Verified Boot State 解析狀態映射錯誤

## CTS Test
`android.keystore.cts.RootOfTrustTest#testVerifiedBootState`

## Failure Log
```
junit.framework.AssertionFailedError: Verified boot state incorrect
Expected: KM_VERIFIED_BOOT_VERIFIED (0)
Actual: KM_VERIFIED_BOOT_SELF_SIGNED (1)

at android.keystore.cts.RootOfTrustTest.testVerifiedBootState(RootOfTrustTest.java:123)
```

## 現象描述
CTS 測試報告 Verified Boot State 解析結果錯誤。
設備是 VERIFIED 狀態，但解析結果顯示為 SELF_SIGNED。
這兩個狀態的安全等級不同，會影響信任決策。

## 提示
- Verified Boot State: VERIFIED(0), SELF_SIGNED(1), UNVERIFIED(2), FAILED(3)
- VERIFIED 表示 bootloader 驗證通過
- 問題可能在於狀態值的映射

## 選項

A) 解析 VerifiedBootState 時索引位移了 1 位

B) VerifiedBootState 的常數定義順序與 KeyMaster 規格相反

C) 解析時使用了 1-based index 而非 0-based

D) switch 語句中 VERIFIED 和 SELF_SIGNED 的 case 值互換了
