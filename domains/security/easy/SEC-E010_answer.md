# SEC-E010 Answer: Attestation Version 返回錯誤值

## 正確答案
**B) `getAttestationVersion()` 硬編碼返回 0**

## 問題根因
在 `Attestation.java` 的 `getAttestationVersion()` 方法中，
沒有返回實際解析的版本值，而是硬編碼返回 0。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
public int getAttestationVersion() {
    return 0;  // BUG: 硬編碼
}

// 正確的代碼
public int getAttestationVersion() {
    return mAttestationVersion;
}
```

## 為什麼其他選項不對

**A)** keymasterVersion 通常也是正整數，不會是 0。

**C)** byte 順序錯誤會導致錯誤的正整數，很難剛好是 0。

**D)** 版本的負值會是負數，不是 0。

## 相關知識
- KeyMaster 是早期的硬體安全模組介面
- KeyMint 是 Android 12+ 引入的新介面
- 版本號用於判斷支援的功能和安全等級

## 難度說明
**Easy** - 返回 0 是最明顯的硬編碼錯誤。
