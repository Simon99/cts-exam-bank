# Q004 Answer: Verified Boot Root of Trust Validation

## 正確答案
**D) LINE R5 邊界檢查錯誤：應該用 `!=` 而非 `<`，且 LINE R7 應該用 `Arrays.equals()` 取反**

## 問題根因
這道題包含多個隱蔽的 bug，需要理解 Java 中 byte array 比較的正確方式以及邏輯運算：

### Bug 1: LINE R3 - 條件邏輯錯誤（最嚴重）
```java
if (mVerifiedBootKey != null || mVerifiedBootKey.length != BOOT_KEY_LENGTH) {
```
**問題**：
1. 使用 `||` 而非 `&&`，邏輯完全相反
2. 當 `mVerifiedBootKey != null` 時，條件已經為真，直接拋出異常
3. 這意味著只要有 boot key（正常情況），就會拋出異常

**正確寫法**：
```java
if (mVerifiedBootKey != null && mVerifiedBootKey.length != BOOT_KEY_LENGTH) {
```

### Bug 2: LINE R5 - 邊界檢查不精確
```java
if (mVerifiedBootHash.length < BOOT_HASH_LENGTH) {
```
**問題**：Hash 長度應該精確匹配，不應允許超過預期長度。

**正確寫法**：
```java
if (mVerifiedBootHash.length != BOOT_HASH_LENGTH) {
```

### Bug 3: LINE R7 - 陣列比較錯誤（關鍵）
```java
return mVerifiedBootKey == zeroKey;
```
**問題**：
1. 使用 `==` 比較兩個 byte array 只比較引用，不比較內容
2. `mVerifiedBootKey` 和 `zeroKey` 是不同的物件，即使內容相同也會返回 false
3. 更關鍵的是，邏輯應該是驗證 boot key **不是**全零，所以應該取反

**正確寫法**：
```java
return !Arrays.equals(mVerifiedBootKey, zeroKey);
```

### 為什麼選 D
雖然 LINE R3 有嚴重 bug，但題目問的是「導致 CTS 失敗」的組合。假設 R3 的 bug 已被其他機制繞過（例如測試環境），則：
- LINE R5 的 `<` 允許超長 hash 通過，這是安全漏洞
- LINE R7 的 `==` 比較永遠返回 false，導致 `isDeviceTrusted()` 失敗
- 選項 D 正確指出這兩個 bug 都存在

## 各選項分析

### A) LINE R2 邏輯錯誤 - 部分正確但不完整
```java
if (mVerifiedBootKey == null && mVerifiedBootState == STATE_VERIFIED) {
```
這行邏輯是正確的：當狀態為 VERIFIED 但沒有 boot key 時拋出異常。用 `&&` 是對的。

### B) LINE R3 運算子錯誤 - 正確識別 bug 但修復不完整
確實 `||` 應該是 `&&`，但修復還需要保持 `!=` 來檢查長度不匹配。

### C) R4 和 R7 組合 - 部分正確
- LINE R4 邏輯正確：`STATE_VERIFIED = 0`，任何 `> 0` 的狀態都不可信
- LINE R7 bug 正確識別，但忽略了 R5 的問題

### D) R5 和 R7 組合 - 最完整
正確識別了兩個會導致驗證失敗的 bug：
1. R5 的邊界檢查不嚴格
2. R7 的陣列比較錯誤導致永遠返回 false

## Bug 位置
- `cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// LINE R3 - 修復邏輯運算子
// 錯誤
if (mVerifiedBootKey != null || mVerifiedBootKey.length != BOOT_KEY_LENGTH) {
// 正確
if (mVerifiedBootKey != null && mVerifiedBootKey.length != BOOT_KEY_LENGTH) {

// LINE R5 - 精確邊界檢查
// 錯誤
if (mVerifiedBootHash.length < BOOT_HASH_LENGTH) {
// 正確
if (mVerifiedBootHash.length != BOOT_HASH_LENGTH) {

// LINE R7 - 使用正確的陣列比較並取反
// 錯誤
return mVerifiedBootKey == zeroKey;
// 正確
return !Arrays.equals(mVerifiedBootKey, zeroKey);
```

## 關鍵知識點

### 1. Java 陣列比較
```java
byte[] a = {1, 2, 3};
byte[] b = {1, 2, 3};

a == b              // false (比較引用)
a.equals(b)         // false (Object.equals 也是比較引用)
Arrays.equals(a, b) // true  (正確的內容比較方式)
```

### 2. Verified Boot 狀態
| 值 | 狀態 | 意義 |
|----|------|------|
| 0 | VERIFIED | 所有分區由 OEM 金鑰驗證 |
| 1 | SELF_SIGNED | boot 分區由自簽金鑰驗證 |
| 2 | UNVERIFIED | 可自由修改 |
| 3 | FAILED | 驗證失敗 |

### 3. Root of Trust 結構
```
RootOfTrust ::= SEQUENCE {
    verifiedBootKey            OCTET STRING,
    deviceLocked               BOOLEAN,
    verifiedBootState          VerifiedBootState,
    verifiedBootHash           OCTET STRING OPTIONAL
}
```

## 為什麼是 Hard 難度
1. **多個 bug 交互** — 需要識別並理解多個錯誤如何組合
2. **Java 陷阱** — `==` 比較陣列是常見錯誤
3. **邏輯運算子** — `&&` vs `||` 在否定條件中容易混淆
4. **領域知識** — 需要理解 Verified Boot 和 Root of Trust 概念
5. **錯誤定位** — 需要從多個 bug 中找出真正導致 CTS 失敗的組合

## 相關知識
- **Android Verified Boot (AVB)** — 確保設備啟動時只執行可信軟體
- **Key Attestation** — 硬體支援的密鑰認證機制
- **Root of Trust** — 信任鏈的起點，通常燒錄在硬體中
- **ASN.1 解析** — Key Attestation 擴展使用的編碼格式
