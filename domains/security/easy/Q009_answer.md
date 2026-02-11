# Q009 Answer: Bound Key Algorithm Check

## 正確答案
**B) LINE A 應該返回 false 而非 true**

## 問題根因
當檢查硬體綁定發生異常時（例如設備不支援硬體安全模組），
錯誤處理返回 `true` 是錯誤的。這違反了「安全默認」原則。

如果無法確認是否有硬體支援，應該假設沒有（返回 false），
而不是假設有（返回 true）。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
} catch (Exception e) {
    Log.e(TAG, "Failed to check hardware backing", e);
    return true;  // BUG: 錯誤時不應該報告有硬體支援
}

// 正確的代碼
} catch (Exception e) {
    Log.e(TAG, "Failed to check hardware backing", e);
    return false;  // 安全默認：假設沒有硬體支援
}
```

## 選項分析
- **A) 錯誤** - "AndroidKeyStore" 是正確的 provider 名稱
- **B) 正確** - 異常情況應該返回安全的默認值（false）
- **C) 錯誤** - load(null) 後 keyStore 已經初始化
- **D) 錯誤** - 雖然是好習慣，但不是導致此 bug 的原因

## 相關知識
- 硬體綁定密鑰存儲在 TEE 或 StrongBox 中
- 安全相關 API 應該遵循「失敗安全」原則
- 報告錯誤的安全能力可能導致應用做出錯誤的安全決策

## 難度說明
**Easy** - 錯誤處理中的默認值問題，理解「安全默認」概念即可識別。
