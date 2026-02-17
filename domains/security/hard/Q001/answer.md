# Q001 Answer: Certificate Pinning Chain Validation

## 正確答案
**D) 問題出在 LINE P2 和 LINE T1 的組合：迴圈越界加上鏈被截斷**

## 問題根因
這道題涉及兩個檔案的 bug 交互，需要同時理解兩個問題：

### Bug 1: NetworkSecurityTrustManager.java (LINE T1)
```java
X509Certificate[] chainToValidate = Arrays.copyOf(certs, certs.length - 1);
```
這行將憑證鏈截斷，移除了最後一個元素（根 CA）。如果 PIN 配置在根 CA 上，這個憑證就不會被驗證。

### Bug 2: PinSet.java (LINE P2)
```java
for (int i = 0; i <= validateCount; i++) {
```
使用 `<=` 而非 `<`，導致迴圈會嘗試存取 `chain[validateCount]`，這是越界的。

### 交互效應
假設原始憑證鏈長度為 3：`[Leaf, Intermediate, Root]`

1. **LINE T1** 截斷後變成長度 2：`[Leaf, Intermediate]`
2. 當 `mIncludeChain=true`，**LINE P1** 計算 `validateCount = 2`
3. **LINE P2** 迴圈 `i = 0, 1, 2`，嘗試存取 `chain[2]`
4. 但截斷後的陣列只有 index 0 和 1，導致 `ArrayIndexOutOfBoundsException`
5. 即使沒有越界，Root CA 也已被移除，PIN 驗證必定失敗

## Bug 位置
- `frameworks/base/core/java/android/security/net/config/PinSet.java`
- `frameworks/base/core/java/android/security/net/config/NetworkSecurityTrustManager.java`

## 修復方式
```java
// NetworkSecurityTrustManager.java - 不應截斷憑證鏈
// 錯誤
X509Certificate[] chainToValidate = Arrays.copyOf(certs, certs.length - 1);
// 正確
X509Certificate[] chainToValidate = validatedChain;  // 使用完整的已驗證鏈

// PinSet.java - 迴圈條件修正
// 錯誤
for (int i = 0; i <= validateCount; i++) {
// 正確
for (int i = 0; i < validateCount; i++) {
```

## 選項分析
- **A) 錯誤** - `validateCount` 的計算是正確的，問題不在這裡
- **B) 部分正確** - LINE P2 確實有 bug，但單獨這個 bug 只會導致越界，不會造成 "No matching pin" 錯誤
- **C) 部分正確** - LINE T1 確實有 bug，但題目的錯誤訊息暗示還有越界問題
- **D) 正確** - 兩個 bug 的組合才能完整解釋錯誤現象

## 為什麼是 Hard 難度
1. **多檔案交互** - 需要同時理解兩個類別如何協作
2. **隱蔽的越界** - LINE P2 的 `<=` 很容易被忽略
3. **業務邏輯** - 需要理解憑證釘選應該驗證整條鏈，包含根 CA
4. **錯誤訊息誤導** - 錯誤訊息說 "No matching pin"，但實際還有越界問題

## 相關知識
- **Certificate Pinning** 是防止中間人攻擊的安全機制
- PIN 通常是憑證公鑰的 SHA-256 雜湊值
- 在憑證鏈驗證中，應該檢查每一層的憑證，包括根 CA
- `Arrays.copyOf(arr, len)` 會複製前 `len` 個元素，不是移除最後一個

## 難度說明
**Hard** - 需要追蹤跨檔案的資料流，理解兩個獨立 bug 如何組合產生觀察到的錯誤現象。
