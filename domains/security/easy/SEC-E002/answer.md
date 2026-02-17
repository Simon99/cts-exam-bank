# SEC-E002 Answer: Security Level 解析返回錯誤值

## 正確答案
**B) `getSecurityLevel()` 方法中硬編碼返回 `KM_SECURITY_LEVEL_SOFTWARE`**

## 問題根因
在 `Attestation.java` 的 `getSecurityLevel()` 方法中，
沒有返回實際解析的安全等級，而是直接返回常數 `KM_SECURITY_LEVEL_SOFTWARE`。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/Attestation.java`

## 修復方式
```java
// 錯誤的代碼
public int getSecurityLevel() {
    return KM_SECURITY_LEVEL_SOFTWARE;  // BUG: 硬編碼
}

// 正確的代碼
public int getSecurityLevel() {
    return mSecurityLevel;
}
```

## 為什麼其他選項不對

**A)** 返回錯誤欄位會導致值不一致，但不一定是 SOFTWARE，需要看具體場景。

**C)** 錯誤映射需要有 switch/if 語句，比硬編碼複雜，且錯誤訊息會顯示映射相關資訊。

**D)** 常數值互換會影響所有使用這些常數的地方，影響範圍太廣，不符合單一 bug。

## 相關知識
- KM_SECURITY_LEVEL_SOFTWARE (0): 密鑰在 Android 系統中
- KM_SECURITY_LEVEL_TRUSTED_ENVIRONMENT (1): 密鑰在 TEE 中
- KM_SECURITY_LEVEL_STRONGBOX (2): 密鑰在獨立安全晶片中
- TEE 是大多數 Android 設備的預設安全環境

## 難度說明
**Easy** - 硬編碼返回值是最直接的錯誤類型。
