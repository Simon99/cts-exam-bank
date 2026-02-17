# Q003 Answer: Attestation Challenge Verification

## 正確答案
**B) LINE A 的迴圈應該是 `i < expectedChallenge.length`（不是 length - 1）**

## 問題根因
迴圈條件 `i < expectedChallenge.length - 1` 導致最後一個位元組沒有被比較。
這是典型的 off-by-one 錯誤。如果挑戰值的最後一個位元組不同，這個比較會錯誤地返回 true。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
for (int i = 0; i < expectedChallenge.length - 1; i++) {  // BUG: 漏掉最後一個位元組
    ...
}

// 正確的代碼
for (int i = 0; i < expectedChallenge.length; i++) {
    ...
}

// 更好的做法
return Arrays.equals(expectedChallenge, this.attestationChallenge);
```

## 選項分析
- **A) 正確但不是 bug** - Arrays.equals() 更好，但手動比較本身不是錯誤
- **B) 正確** - off-by-one 錯誤，漏掉最後一個位元組
- **C) 錯誤** - null 檢查順序是正確的
- **D) 錯誤** - 挑戰值需要精確匹配，不需要雜湊

## 相關知識
- Off-by-one 錯誤是最常見的邊界條件 bug 之一
- 認證挑戰用於防止重放攻擊
- 挑戰值通常是隨機生成的，需要精確匹配

## 難度說明
**Medium** - 經典的 off-by-one 錯誤，需要仔細閱讀迴圈條件。
