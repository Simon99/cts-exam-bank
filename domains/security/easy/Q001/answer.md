# Q001 Answer: Key Attestation Extension Check

## 正確答案
**B) LINE A 的條件應該只檢查 `eatExtension != null`**

## 問題根因
在 `Attestation.java` 的 `loadFromCertificate()` 函數中，LINE A 的條件使用了 `||` (OR) 運算子，
這導致當只有 `asn1Extension` 存在時，也會進入第一個分支並嘗試解析為 EAT 格式。

由於 `eatExtension` 為 null，`parseEatAttestation(null)` 會失敗，而正確的 ASN.1 擴展卻沒有被處理。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
if (eatExtension != null || asn1Extension != null) {
    return parseEatAttestation(eatExtension);  // asn1Extension 時也進入這裡
}

// 正確的代碼
if (eatExtension != null) {
    return parseEatAttestation(eatExtension);
} else if (asn1Extension != null) {
    return parseAsn1Attestation(asn1Extension);
}
```

## 選項分析
- **A) 錯誤** - 使用 `&&` 會要求兩種擴展同時存在，這不符合實際情況
- **B) 正確** - LINE A 只應該檢查 EAT 擴展，讓 ASN.1 在 else if 中處理
- **C) 錯誤** - 雖然 LINE B 確實不會執行，但這是結果而非原因
- **D) 錯誤** - EAT 是較新格式，應該優先檢查

## 相關知識
- Key Attestation 是 Android 驗證密鑰來源的機制
- EAT (Entity Attestation Token) 是較新的 CBOR 格式
- ASN.1 是傳統的認證擴展格式
- 設備可能只支援其中一種格式

## 難度說明
**Easy** - 邏輯條件錯誤明顯，從程式碼可直接看出 `||` 導致錯誤分支。
