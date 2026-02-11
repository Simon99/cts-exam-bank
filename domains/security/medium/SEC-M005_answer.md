# SEC-M005 Answer: User Auth Type 位元運算錯誤

## 正確答案
**A) 解析 UserAuthType 時使用 `&=` 而非 `|=` 累加認證類型**

## 問題根因
在 `AuthorizationList.java` 解析 UserAuthType 時，
使用了位元 AND (`&=`) 而非 OR (`|=`) 來累加認證類型，
導致多種認證類型組合時結果為 0。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
private void parseUserAuthType(ASN1Sequence authTypes) {
    mUserAuthType = 0;
    for (ASN1Encodable type : authTypes) {
        mUserAuthType &= ((ASN1Integer) type).intValueExact();  // BUG
    }
}

// 正確的代碼
private void parseUserAuthType(ASN1Sequence authTypes) {
    mUserAuthType = 0;
    for (ASN1Encodable type : authTypes) {
        mUserAuthType |= ((ASN1Integer) type).intValueExact();
    }
}
```

## 為什麼其他選項不對

**B)** 常數定義錯誤會在所有使用這些常數的地方產生問題，不只是這個測試。

**C)** 位元反轉 (`~`) 會產生負數或很大的正數，不會剛好是 0。

**D)** 這基本上是 A 的另一種描述，但 A 更直接指出問題所在。

## 相關知識
- HW_AUTH_PASSWORD = 1 (0b01)
- HW_AUTH_FINGERPRINT = 2 (0b10)
- 1 | 2 = 3, 1 & 2 = 0
- 位元遮罩用於表示多重選項的組合

## 難度說明
**Medium** - 需要理解位元運算和遮罩的概念。
