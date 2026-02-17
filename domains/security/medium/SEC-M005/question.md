# SEC-M005: User Auth Type 位元運算錯誤

## CTS Test
`android.keystore.cts.AuthorizationListTest#testUserAuthType`

## Failure Log
```
junit.framework.AssertionFailedError: User auth type validation failed
Expected: HW_AUTH_FINGERPRINT | HW_AUTH_PASSWORD (3)
Actual: HW_AUTH_FINGERPRINT & HW_AUTH_PASSWORD (0)

at android.keystore.cts.AuthorizationListTest.testUserAuthType(AuthorizationListTest.java:312)
```

## 現象描述
CTS 測試報告使用者認證類型的組合值不正確。
預期是 FINGERPRINT(1) OR PASSWORD(2) = 3，
實際得到的是 FINGERPRINT(1) AND PASSWORD(2) = 0。

## 提示
- User Auth Type 使用位元遮罩組合多種認證方式
- OR (`|`) 用於組合位元，AND (`&`) 用於檢查位元
- 問題可能在於解析時的位元運算

## 選項

A) 解析 UserAuthType 時使用 `&=` 而非 `|=` 累加認證類型

B) UserAuthType 常數定義使用了錯誤的位元位置

C) `getUserAuthType()` 返回了位元反轉的結果

D) 解析時將第一個認證類型設為 0 初始值後用 `&` 運算
