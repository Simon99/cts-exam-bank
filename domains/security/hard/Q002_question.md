# Q002: NetworkSecurityTrustManager 證書釘選繞過

## CTS Test
`android.security.net.config.cts.InvalidPinTest#testPinFailure`

## Failure Log
```
junit.framework.AssertionFailedError: 
Expected: TLS connection to fail due to invalid pin
Actual: Connection succeeded unexpectedly

Test configuration has an invalid pin for android.com, but the connection was not rejected.
Pin verification should have failed but was bypassed.

at android.security.net.config.cts.InvalidPinTest.testPinFailure(InvalidPinTest.java:28)
```

## 現象描述
CTS 測試配置了一個錯誤的 Certificate Pin，預期連線應該失敗，但連線卻成功了。
這表示證書釘選(Certificate Pinning)機制被繞過，可能造成中間人攻擊風險。

## 相關程式碼片段
```java
// NetworkSecurityTrustManager.java
private void checkPins(List<X509Certificate> chain) throws CertificateException {
    PinSet pinSet = mNetworkSecurityConfig.getPins();
    if (pinSet.pins.isEmpty()
            || System.currentTimeMillis() > pinSet.expirationTime
            || !isPinningEnforced(chain)) {
        return;  // Skip pin verification
    }
    // ... pin verification logic ...
}

private boolean isPinningEnforced(List<X509Certificate> chain) throws CertificateException {
    if (chain.isEmpty()) {
        return false;
    }
    X509Certificate anchorCert = chain.get(chain.size() - 1);
    TrustAnchor chainAnchor =
            mNetworkSecurityConfig.findTrustAnchorBySubjectAndPublicKey(anchorCert);
    if (chainAnchor == null) {
        throw new CertificateException("Trusted chain does not end in a TrustAnchor");
    }
    return /* ??? */;  // Bug is here
}
```

## 提示
- `TrustAnchor.overridesPins` 表示此信任錨點是否可以繞過 pin 驗證（例如用戶手動安裝的 CA）
- 系統預設的 CA 通常設定 `overridesPins = false`
- 用戶安裝的 CA 設定 `overridesPins = true` 以便進行流量檢查
- `isPinningEnforced()` 返回 `true` 時，`checkPins()` 會執行 pin 驗證

## 選項

A) `return chainAnchor.overridesPins;` — 直接返回 overridesPins 值，忘記取反

B) `return chain.size() > 0;` — 只檢查鏈是否非空，忽略 overridesPins 設定

C) `return chainAnchor != null;` — 只檢查 anchor 是否存在，忽略 overridesPins 設定

D) `return false;` — 直接返回 false，永遠不強制執行 pinning
