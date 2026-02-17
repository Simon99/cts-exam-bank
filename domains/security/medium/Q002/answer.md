# Q002 Answer: KeyMaster Version Range Validation

## 正確答案
**A) LINE A 的範圍應該是 `version <= 4`**

## 問題根因
KeyMaster 的有效版本是 1-4，但代碼錯誤地使用了 `version <= 5`，
這導致無效版本 5 也被接受。版本 5-99 是保留範圍，不應該被視為有效版本。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
if (version >= 1 && version <= 5) {  // BUG: 5 不是有效版本
    return;
}

// 正確的代碼
if (version >= 1 && version <= 4) {  // KeyMaster 最高版本是 4
    return;
}
```

## 選項分析
- **A) 正確** - KeyMaster 最高版本是 4，邊界條件錯誤
- **B) 錯誤** - KeyMint 沒有上限，100+ 都是有效的
- **C) 錯誤** - 邏輯結構不是問題
- **D) 錯誤** - 檢查順序不影響結果

## 相關知識
- KeyMaster 1.0-4.0：Android 6.0-11 的硬體密鑰管理
- KeyMint 1.0+（版本 100+）：Android 12+ 的新架構
- 版本 5-99 是保留範圍，避免版本號衝突

## 難度說明
**Medium** - 需要了解 KeyMaster/KeyMint 版本歷史才能識別邊界條件錯誤。
