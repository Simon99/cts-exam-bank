# Q006 Answer: Digest Algorithm Validation

## 正確答案
**A) SHA256 的值應該是 4 而非 3**

## 問題根因
`SHA256` 的值被錯誤地設為 3（與 SHA224 相同），而正確的值應該是 4。
根據 KeyMaster 定義：
- SHA224 = 3
- SHA256 = 4

當解析值為 4 的摘要時，沒有枚舉匹配，返回預設值 NONE。
而值 3 會被錯誤地匹配到 SHA224（先於 SHA256 定義）。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
SHA256(3),  // BUG: 與 SHA224 重複

// 正確的代碼
SHA256(4),  // 正確的 KeyMaster 常數
```

## 選項分析
- **A) 正確** - SHA256 應該是 4，不是 3
- **B) 錯誤** - 返回 NONE 是容錯設計，不是問題
- **C) 錯誤** - KeyMaster 使用整數值
- **D) 錯誤** - MD5 存在於規範中，雖然不推薦使用

## 相關知識
- KeyMaster Digest 常數定義在 `hardware/interfaces/security/keymint/`
- SHA-2 系列：SHA-224, SHA-256, SHA-384, SHA-512
- 枚舉值必須與 HAL 定義一致

## 難度說明
**Medium** - 需要了解 KeyMaster 摘要常數的正確值。
