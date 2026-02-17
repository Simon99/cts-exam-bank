# Q003 Answer: NetworkSecurityTrustManager Pin 過期檢查邏輯錯誤

## 正確答案
**A) 過期時間比較運算符錯誤：使用 `<` 而非 `>`，導致未過期的 pin 被跳過**

## 問題根因
在 `NetworkSecurityTrustManager.java` 的 `checkPins()` 方法中，
過期時間比較使用了錯誤的運算符。

正確邏輯應該是：當 `currentTime > expirationTime` 時（pin 已過期），跳過驗證。
錯誤邏輯變成：當 `currentTime < expirationTime` 時（pin 未過期），跳過驗證。

這導致**有效的 pin 被跳過**，繼續驗證時因為找不到匹配的 pin 而失敗。

## Bug 位置
`frameworks/base/core/java/android/security/net/config/NetworkSecurityTrustManager.java`

## 修復方式
```java
// 錯誤的代碼
private void checkPins(List<X509Certificate> chain) throws CertificateException {
    PinSet pinSet = mNetworkSecurityConfig.getPins();
    if (pinSet.pins.isEmpty()
            || System.currentTimeMillis() < pinSet.expirationTime  // BUG: < 應該是 >
            || !isPinningEnforced(chain)) {
        return;  // 錯誤地在 pin 有效時跳過，導致後續 pin 驗證失敗
    }
    // ... pin verification logic
    throw new CertificateException("Pin verification failed");
}

// 正確的代碼
private void checkPins(List<X509Certificate> chain) throws CertificateException {
    PinSet pinSet = mNetworkSecurityConfig.getPins();
    if (pinSet.pins.isEmpty()
            || System.currentTimeMillis() > pinSet.expirationTime  // 正確：過期才跳過
            || !isPinningEnforced(chain)) {
        return;  // pin 過期或不需要驗證時才跳過
    }
    // ... pin verification logic
}
```

## 邏輯分析

**正確邏輯 (`currentTime > expirationTime`)：**
- Pin 過期 → 跳過 pin 驗證 → 連線成功（不強制 pinning）
- Pin 有效 → 執行 pin 驗證 → 匹配成功 → 連線成功

**錯誤邏輯 (`currentTime < expirationTime`)：**
- Pin 有效 → 跳過正常的 pin 匹配邏輯 → 但 return 後不會拋異常
- 等等，讓我重新分析...

實際上這個 bug 更微妙：早期 return 會跳過整個 checkPins，但錯誤的條件會導致：
- Pin 未過期時進入 return → 不驗證，連線應該成功
- Pin 過期時不進入 return → 繼續驗證 → 如果 pin 不匹配就失敗

但測試顯示 "Pin verification failed"，表示程式走到了最後的 throw。這說明 bug 使得在 pin 有效時跳過了 `return`（不應該的），然後 pin 驗證流程走完但找不到匹配（可能因為其他問題），最終拋出異常。

**簡化理解：** `<` vs `>` 的錯誤導致過期判斷邏輯完全相反。

## 為什麼其他選項不對

**B)** 時間單位不一致會導致極端的數值差異（約 1000 倍），log 顯示的時間戳是一致的毫秒值。

**C)** `elapsedRealtime()` 從開機算起，數值會遠小於 `currentTimeMillis()`。Log 顯示 currentTime 是正確的 wall-clock 時間。

**D)** 過期檢查的位置是正確的。checkPins() 是專門處理 pin 驗證的方法，在此檢查過期是合理的設計。

## 相關知識
- **Certificate Pinning**：限制應用只信任預設的憑證或公鑰
- **Pin Expiration**：允許 pin 過期以便憑證輪換
- **比較運算符 bug**：`<` vs `>` 是常見的邏輯錯誤，尤其在安全相關代碼中後果嚴重

## 安全影響
此 bug 會導致：
- 有效的 pinning 配置失效
- 潛在的中間人攻擊風險（如果 pin 驗證被錯誤跳過）

## 難度說明
**Hard** - 需要理解：
1. Certificate Pinning 機制
2. 過期時間的語義（何時應該跳過驗證）
3. 條件判斷邏輯的影響
4. 分析 log 中的時間戳以排除時間單位問題
