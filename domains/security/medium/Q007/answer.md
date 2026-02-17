# Q007 Answer: User Auth Type Parsing

## 正確答案
**D) 選項 B 和 C 都需要修正**

## 問題根因
這段代碼有兩個問題：

1. **預設值錯誤** - `userAuthType` 初始化為 `AUTH_TYPE_PASSWORD (1)`，
   應該初始化為 0（無認證要求）

2. **使用 OR 而非賦值** - `userAuthType | value` 會保留預設值的位元，
   應該直接賦值 `userAuthType = value`

結果：當解析 BIOMETRIC(2) 時，結果變成 `1 | 2 = 3`（兩種都要求）

## Bug 位置
`cts/tests/security/src/android/keystore/cts/AuthorizationList.java`

## 修復方式
```java
// 錯誤的代碼
private int userAuthType = AUTH_TYPE_PASSWORD;  // 預設值錯誤

public void parseUserAuthType(ASN1Integer value) {
    userAuthType = userAuthType | value.intValueExact();  // 使用 OR 累加
}

// 正確的代碼
private int userAuthType = 0;  // 無預設認證要求

public void parseUserAuthType(ASN1Integer value) {
    userAuthType = value.intValueExact();  // 直接賦值
}
```

## 選項分析
- **A) 錯誤** - 常數值定義正確
- **B) 正確但不完整** - 預設值確實應該是 0
- **C) 正確但不完整** - 確實應該用賦值
- **D) 正確** - 兩個問題都需要修正

## 相關知識
- 用戶認證類型是位元標誌，可以組合多種認證方式
- 但解析時應該使用認證擴展中記錄的值，而非累加
- 這是解析邏輯和初始化邏輯的雙重錯誤

## 難度說明
**Medium** - 需要識別多個相關問題，理解位元運算的影響。
