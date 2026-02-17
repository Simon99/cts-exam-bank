# Q009 Answer: Root of Trust Attestation Version Handling

## 正確答案
**A) LINE R1 條件錯誤：`attestationVersion < 100` 排除了所有 KeyMint 版本，應該移除此限制**

## 問題根因
`RootOfTrust.java` 的 LINE R1 有一個版本判斷錯誤：

```java
if (attestationVersion >= 3 && attestationVersion < 100) {
    mVerifiedBootHash = Asn1Utils.getByteArrayFromAsn1(...);
} else {
    mVerifiedBootHash = null;
}
```

### 版本編號體系
Android 的 Key Attestation 有兩套版本體系：

| 類型 | 版本 | attestationVersion |
|------|------|-------------------|
| KeyMaster 1.0 | KM 1.0 | 1 |
| KeyMaster 2.0 | KM 2.0 | 2 |
| KeyMaster 3.0 | KM 3.0 | 3 |
| KeyMaster 4.0 | KM 4.0 | 4 |
| KeyMint 1.0 | KM 100 | 100 |
| KeyMint 2.0 | KM 200 | 200 |
| KeyMint 3.0 | KM 300 | 300 |

### Bug 分析
`verifiedBootHash` 從 attestationVersion 3 開始引入，意味著：
- KeyMaster 3.0+ (version 3, 4, 40, 41) 應該有 verifiedBootHash
- KeyMint 1.0+ (version 100, 200, 300) **一定**有 verifiedBootHash

但 `attestationVersion < 100` 這個條件把所有 KeyMint 版本都排除了：
- 當 `attestationVersion = 100` (KeyMint 1.0)
- `100 >= 3` 為 true
- `100 < 100` 為 false
- 整個條件為 false → `mVerifiedBootHash = null`

## 選項分析

### A) ✅ 正確
LINE R1 的 `attestationVersion < 100` 是多餘且錯誤的限制。正確邏輯應該是：
```java
if (attestationVersion >= 3) {
    mVerifiedBootHash = ...;
}
```

### B) ❌ 錯誤
雖然 LINE T1 使用 `> 3` 而非 `>= 3` 可能看起來有問題，但實際上：
- CTS 測試的設計意圖是測試 v3 **之後**的版本
- 即使改成 `>= 3`，問題仍然存在，因為 RootOfTrust 根本沒有解析出 hash
- 錯誤訊息顯示 attestationVersion=100，這個值無論 `> 3` 或 `>= 3` 都會觸發檢查

### C) ❌ 部分正確但不完整
雖然 LINE T1 的 `> 3` 不夠精確，但這不是導致此測試失敗的根本原因。根本原因是 LINE R1 讓 KeyMint 設備無法解析 verifiedBootHash。

### D) ❌ 錯誤
LINE T2 的邊界檢查是正確的：
- `KM_VERIFIED_BOOT_VERIFIED = 0`
- `KM_VERIFIED_BOOT_FAILED = 3`
- `bootState >= 0 && bootState <= 3` 是合理的範圍檢查

## Bug 位置
- `cts/tests/security/src/android/keystore/cts/RootOfTrust.java` LINE R1

## 修復方式
```java
// 錯誤
if (attestationVersion >= 3 && attestationVersion < 100) {
    mVerifiedBootHash = ...;
}

// 正確
if (attestationVersion >= 3) {
    mVerifiedBootHash = Asn1Utils.getByteArrayFromAsn1(
        sequence.getObjectAt(VERIFIED_BOOT_HASH_INDEX));
}
```

## 為什麼是 Hard 難度
1. **版本體系理解** — 需要知道 KeyMaster vs KeyMint 的版本編號差異
2. **隱蔽的邊界條件** — `< 100` 看起來像是合理的上界檢查
3. **誤導的測試程式碼** — LINE T1 的 `> 3` 可能讓人懷疑測試本身有問題
4. **歷史背景知識** — 需要理解為什麼存在兩套版本體系

## 相關知識

### 為什麼有兩套版本體系？
- **KeyMaster** (KM 1.0-4.1) 是原本的密鑰管理模組
- **KeyMint** 是 Android 12 開始的新架構，版本從 100 開始避免混淆
- attestationVersion 直接對應模組版本號

### verifiedBootHash 的作用
- 提供系統啟動鏈的密碼學雜湊值
- 可用於驗證設備是否運行預期的系統映像
- 是 Verified Boot 2.0 (AVB) 的重要組成部分

## 難度說明
**Hard** — 需要深入理解 Android Key Attestation 的版本演進歷史，以及 KeyMaster 和 KeyMint 不同的版本編號體系。條件判斷的 bug 很隱蔽，容易被忽視。
