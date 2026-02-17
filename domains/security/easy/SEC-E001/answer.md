# SEC-E001 Answer: Attestation 擴展格式檢查錯誤

## 正確答案
**C) `loadFromCertificate()` 中將 `eatExtension != null` 錯寫為 `eatExtension == null`**

## 問題根因
在 `Attestation.java` 的 `loadFromCertificate()` 方法中，
檢查 EAT 擴展是否存在的條件被反轉了，導致即使有 EAT 擴展也會被跳過。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
byte[] eatExtension = x509Cert.getExtensionValue(EAT_OID);
if (eatExtension == null) {  // BUG: 條件反轉
    // 解析 EAT 格式
    parseEatExtension(eatExtension);
} else {
    // Fallback 到 ASN1
    parseAsn1Extension(asn1Extension);
}

// 正確的代碼
byte[] eatExtension = x509Cert.getExtensionValue(EAT_OID);
if (eatExtension != null) {
    // 解析 EAT 格式
    parseEatExtension(eatExtension);
} else {
    // Fallback 到 ASN1
    parseAsn1Extension(asn1Extension);
}
```

## 為什麼其他選項不對

**A)** 檢查順序顛倒會導致 ASN1 被優先使用，但如果 ASN1 不存在則會失敗，錯誤訊息會不同。

**B)** 使用 `||` 連接條件會導致條件過於寬鬆，不會產生「錯誤識別為 ASN1」的現象。

**D)** 如果缺少 OID 定義，程式碼在編譯時就會報錯，不會進入執行階段。

## 相關知識
- Key Attestation 是 Android 驗證硬體安全模組的機制
- EAT (Entity Attestation Token) 是較新的格式標準
- 條件判斷的 `!=` 和 `==` 是常見的低級錯誤

## 難度說明
**Easy** - 條件反轉是明顯的邏輯錯誤，從 fail log 可推斷。
