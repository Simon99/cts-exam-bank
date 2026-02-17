# SEC-E006: NoAuthRequired 標記錯誤處理

## CTS Test
`android.keystore.cts.AuthorizationListTest#testNoAuthRequired`

## Failure Log
```
junit.framework.AssertionFailedError: noAuthRequired flag incorrect
Expected: true (key does not require auth)
Actual: false

at android.keystore.cts.AuthorizationListTest.testNoAuthRequired(AuthorizationListTest.java:210)
```

## 現象描述
CTS 測試報告一個設定為不需要使用者認證的密鑰，
其 `isNoAuthRequired()` 方法返回 false。
這導致不需要認證的密鑰被錯誤地要求認證。

## 提示
- NoAuthRequired 是一個布林標記
- 該 TAG 存在即表示不需要認證
- 問題可能在於布林值的處理邏輯

## 選項

A) `isNoAuthRequired()` 返回了 `!mNoAuthRequired` 而非 `mNoAuthRequired`

B) 解析 TAG 時將 NoAuthRequired 設為 false 而非 true

C) `isNoAuthRequired()` 中的條件判斷使用了 `&&` 而非 `||`

D) NoAuthRequired TAG 的解析被完全跳過了
