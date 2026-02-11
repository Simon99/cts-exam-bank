# SEC-M006 Answer: Verified Boot State 解析狀態映射錯誤

## 正確答案
**C) 解析時使用了 1-based index 而非 0-based**

## 問題根因
在 `RootOfTrust.java` 解析 VerifiedBootState 時，
對解析出的值加了 1 才使用，導致所有狀態都向後偏移了一位。
VERIFIED(0) 變成了 SELF_SIGNED(1)。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼
private void parseVerifiedBootState(ASN1Integer value) {
    int state = value.intValueExact() + 1;  // BUG: 不該加 1
    mVerifiedBootState = VerifiedBootState.fromValue(state);
}

// 正確的代碼
private void parseVerifiedBootState(ASN1Integer value) {
    int state = value.intValueExact();
    mVerifiedBootState = VerifiedBootState.fromValue(state);
}
```

## 為什麼其他選項不對

**A)** 「索引位移 1 位」和 C 本質上相同，但 C 更精確描述了問題（加 1）。

**B)** 常數定義順序錯誤會影響所有狀態的對應，不只是 0→1 的偏移。

**D)** case 互換只會影響這兩個特定狀態，但從錯誤訊息看是系統性的偏移。

## 相關知識
- Verified Boot 是 Android 的安全啟動機制
- VERIFIED 狀態表示系統完全可信
- SELF_SIGNED 表示系統使用自簽名，信任度較低
- 0-based vs 1-based indexing 是常見的偏移錯誤

## 難度說明
**Medium** - 需要理解狀態映射和索引偏移的關係。
