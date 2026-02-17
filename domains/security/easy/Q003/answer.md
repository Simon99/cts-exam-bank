# Q003 Answer: Key Algorithm Validation

## 正確答案
**B) LINE A 應該使用 ALGORITHM_EC 常數而非硬編碼的 1**

## 問題根因
在 `getAlgorithm()` 函數中，EC 算法的 case 使用了硬編碼的 `1`，
但 `ALGORITHM_EC` 的實際值是 `3`，而 `1` 實際上對應 `ALGORITHM_RSA`。

這導致 EC 算法（值為 3）無法匹配任何 case，進入 default 返回 UNKNOWN，
而前面的 `case ALGORITHM_RSA` 已經正確處理了值 1。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
case 1:  // BUG: 硬編碼錯誤，應該是 ALGORITHM_EC (3)
    return Algorithm.EC;

// 正確的代碼
case ALGORITHM_EC:  // 使用常數，值為 3
    return Algorithm.EC;
```

## 選項分析
- **A) 錯誤** - ALGORITHM_EC = 3 是正確的 KeyMaster 定義
- **B) 正確** - 使用硬編碼 1 與 ALGORITHM_RSA 重複，且值錯誤
- **C) 錯誤** - 缺少 HMAC 不會影響 EC 的解析
- **D) 錯誤** - 返回 UNKNOWN 是合理的容錯處理

## 相關知識
- KeyMaster 算法定義在 `hardware/interfaces/security/keymint/`
- 使用常數而非魔術數字是良好的編碼實踐
- 授權列表記錄密鑰的各種屬性和限制

## 難度說明
**Easy** - 明顯的硬編碼錯誤，對比常數定義即可發現問題。
