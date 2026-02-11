# SEC-M007: KeyChain getPrivateKey 異常處理錯誤

## CTS Test
`android.keychain.cts.KeyChainTest#testGetPrivateKeyInvalidAlias`

## Failure Log
```
java.lang.RuntimeException: android.os.RemoteException: Service not available
at android.security.KeyChain.getPrivateKey(KeyChain.java:234)
at android.keychain.cts.KeyChainTest.testGetPrivateKeyInvalidAlias(KeyChainTest.java:189)

Expected: KeyChainException with message "Invalid alias"
Actual: RuntimeException wrapping RemoteException
```

## 現象描述
當使用無效的別名呼叫 `KeyChain.getPrivateKey()` 時，
應該拋出 `KeyChainException`，但實際拋出的是包裝了 `RemoteException` 的 `RuntimeException`。

## 提示
- KeyChain 通過 Binder 與系統服務通訊
- RemoteException 需要被轉換為適當的 API 異常
- 問題可能在於 catch 區塊的異常處理

## 選項

A) catch 區塊中將 RemoteException 包裝成 RuntimeException 而非 KeyChainException

B) catch 區塊完全缺失，RemoteException 直接傳播

C) 異常處理的順序錯誤，RemoteException 的 catch 在 KeyChainException 之後

D) 使用了 throws 宣告而非 try-catch 處理 RemoteException
