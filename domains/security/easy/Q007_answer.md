# Q007 Answer: Device Locked State

## 正確答案
**B) LINE A 不應該有 `!` 取反操作**

## 問題根因
在解析 `deviceLocked` 值時，代碼錯誤地使用了取反操作 `!lockedValue.isTrue()`。
這導致當 ASN.1 資料表示設備鎖定（true）時，解析結果變成未鎖定（false），反之亦然。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/RootOfTrust.java`

## 修復方式
```java
// 錯誤的代碼
this.deviceLocked = !lockedValue.isTrue();  // BUG: 不應該取反

// 正確的代碼
this.deviceLocked = lockedValue.isTrue();
```

## 選項分析
- **A) 錯誤** - 索引 1 是 deviceLocked 的正確位置（0 是 verifiedBootKey）
- **B) 正確** - 取反操作導致邏輯顛倒
- **C) 錯誤** - deviceLocked 確實是布林值
- **D) 錯誤** - 類型轉換已經隱含了非 null 假設

## 相關知識
- RootOfTrust 結構：verifiedBootKey, deviceLocked, verifiedBootState, verifiedBootHash
- deviceLocked = true 表示 bootloader 處於鎖定狀態（安全）
- Verified Boot 需要 bootloader 鎖定才能保證系統完整性

## 難度說明
**Easy** - 單一的 `!` 運算子錯誤，從邏輯上很容易發現問題。
