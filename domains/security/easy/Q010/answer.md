# Q010 Answer: Attestation Version Check

## 正確答案
**A) LINE A 的計算應該是 `rawVersion - 100 + 3`**

## 問題根因
KeyMint 內部版本從 100 開始（100, 101, 102...），對外顯示為 3, 4, 5...。
正確的轉換公式是 `rawVersion - 100 + 3`，但代碼錯誤地使用了 `+ 2`。

例如：
- 內部版本 100 → 應該顯示為 3（KeyMint 1.0）
- 內部版本 101 → 應該顯示為 4（KeyMint 2.0）

錯誤公式導致顯示為 2, 3, 4...，少了 1。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
if (rawVersion >= 100) {
    return rawVersion - 100 + 2;  // BUG: 結果少 1
}

// 正確的代碼
if (rawVersion >= 100) {
    return rawVersion - 100 + 3;  // KeyMint 100 = version 3
}
```

## 選項分析
- **A) 正確** - 計算公式錯誤，應該 +3 而非 +2
- **B) 錯誤** - `>= 100` 是正確的（100 是第一個 KeyMint 版本）
- **C) 錯誤** - KeyMint 確實需要版本轉換
- **D) 錯誤** - 使用常數是好習慣，但不是導致 bug 的原因

## 相關知識
- KeyMaster 1.0-4.0：認證版本 1-4
- KeyMint 1.0+：認證版本從 3 開始（跳過舊版本號）
- 內部使用 100+ 避免與 KeyMaster 版本衝突

## 難度說明
**Easy** - 簡單的數學計算錯誤，從期望值和實際值的差異即可推斷。
