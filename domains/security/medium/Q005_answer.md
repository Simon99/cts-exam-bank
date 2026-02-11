# Q005 Answer: Key Purpose Validation

## 正確答案
**B) 應該在解析前清除 purposes 集合**

## 問題根因
`purposes` 集合在初始化時就包含了 DEFAULT_PURPOSES（ENCRYPT, DECRYPT）。
當解析實際的用途時，只是把新的用途添加進去，沒有清除預設值。

這導致解析後的用途集合包含了預設值 + 實際值，而非僅實際值。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public void parsePurposes(ASN1Sequence sequence) {
    for (int i = 0; i < sequence.size(); i++) {
        // 只添加，沒有清除預設值
        purposes.add(purposeValue.intValueExact());
    }
}

// 正確的代碼
public void parsePurposes(ASN1Sequence sequence) {
    purposes.clear();  // 先清除預設值
    for (int i = 0; i < sequence.size(); i++) {
        ASN1Integer purposeValue = (ASN1Integer) sequence.getObjectAt(i);
        purposes.add(purposeValue.intValueExact());
    }
}
```

## 選項分析
- **A) 錯誤** - Set 使用 add()，put() 是 Map 的方法
- **B) 正確** - 需要先清除再添加，避免累加
- **C) 部分正確** - 空預設值可以避免問題，但真正的 bug 是沒有清除
- **D) 錯誤** - 容器類型不是問題

## 相關知識
- 密鑰用途控制密鑰可以執行的操作
- 常見用途：SIGN, VERIFY, ENCRYPT, DECRYPT, WRAP_KEY
- 限制用途是重要的安全措施

## 難度說明
**Medium** - 類似 Q005 Easy（Padding），但需要追蹤初始化流程。
