# SEC-E004 Answer: Key Size 驗證邊界錯誤

## 正確答案
**C) `validateKeySize()` 中將 `keySize >= 2048` 錯寫為 `keySize > 2048`**

## 問題根因
在 `AuthorizationList.java` 的 `validateKeySize()` 方法中，
檢查密鑰大小是否有效時，使用了 `>` 而非 `>=`，
導致剛好等於 2048 的密鑰被判定為無效。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
private boolean validateKeySize(int keySize) {
    return keySize > 2048 && keySize <= 4096;  // BUG: > 應為 >=
}

// 正確的代碼
private boolean validateKeySize(int keySize) {
    return keySize >= 2048 && keySize <= 4096;
}
```

## 為什麼其他選項不對

**A)** 這個選項描述的是上限檢查，但錯誤發生在下限，且 2048 不接近上限。

**B)** 使用 `<=` 會讓更小的值通過，不會把 2048 判定為無效。

**D)** 如果 MIN_KEY_SIZE 設為 2049，錯誤訊息應該會提到常數值相關的資訊。

## 相關知識
- RSA 2048 是目前推薦的最小安全密鑰長度
- 邊界條件（off-by-one）錯誤是常見的程式錯誤
- `>=` vs `>` 的差異在邊界值時特別重要

## 難度說明
**Easy** - 經典的 off-by-one 錯誤，從測試的邊界值可以直接判斷。
