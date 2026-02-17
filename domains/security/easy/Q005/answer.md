# Q005 Answer: Padding Mode Validation

## 正確答案
**C) LINE A 應該取消註解，清除預設值**

## 問題根因
`paddingModes` 在初始化時就包含了三種預設填充模式（NONE, PKCS7, RSA_OAEP）。
在 `parsePaddingModes()` 解析實際的填充模式時，`clear()` 被註解掉了，
導致解析後的模式被添加到預設值上，而非替換預設值。

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
public void parsePaddingModes(ASN1Sequence sequence) {
    // paddingModes.clear();  // BUG: 被註解掉，預設值未清除
    for (int i = 0; i < sequence.size(); i++) {
        ...
    }
}

// 正確的代碼
public void parsePaddingModes(ASN1Sequence sequence) {
    paddingModes.clear();  // 清除預設值
    for (int i = 0; i < sequence.size(); i++) {
        ...
    }
}
```

## 選項分析
- **A) 錯誤** - Set 使用 add()，put() 是 Map 的方法
- **B) 錯誤** - HashSet 可以避免重複，是正確的選擇
- **C) 正確** - 不清除預設值導致錯誤的填充模式列表
- **D) 錯誤** - 返回副本是好習慣但與此 bug 無關

## 相關知識
- 常見填充模式：NONE, PKCS7, RSA_PKCS1, RSA_OAEP
- 授權列表限制密鑰只能使用指定的參數
- 解析時應該清除預設值再添加實際值

## 難度說明
**Easy** - 被註解的 clear() 是明顯線索，指向預設值未清除的問題。
