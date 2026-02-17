# Q003: NetworkSecurityTrustManager Pin 過期檢查邏輯錯誤

## CTS Test
`android.security.net.config.cts.CertificatePinningTest#testPinValidation`

## Failure Log
```
javax.net.ssl.SSLHandshakeException: Pin verification failed
    at android.security.net.config.NetworkSecurityTrustManager.checkPins(NetworkSecurityTrustManager.java:132)
    at android.security.net.config.NetworkSecurityTrustManager.checkServerTrusted(NetworkSecurityTrustManager.java:98)
    ...

Test configuration:
  - Pin expiration: 2099-12-31 (far future, should be VALID)
  - Current time: 2025-02-11
  - Expected: Connection should succeed (pin not expired, certificate matches pin)
  - Actual: Pin verification failed

Additional log:
  PinSet expiration check: currentTime=1739260800000, expirationTime=4102358400000
  Pins are being skipped even though they haven't expired
```

## 現象描述
CTS 測試 Certificate Pinning 驗證時失敗。測試配置了一個有效的 pin，過期時間設定在遙遠的未來。
預期連線應該成功（pin 尚未過期且憑證匹配），但實際拋出 "Pin verification failed"。

Log 顯示 "Pins are being skipped even though they haven't expired"，
意味著 pin 過期判斷邏輯可能有問題，導致有效的 pin 被錯誤跳過。

## 提示
- Certificate Pinning 是一種安全機制，限制應用程式只信任特定憑證
- Pin 可以設定過期時間，過期後不再強制執行 pinning
- 問題在於過期時間的比較邏輯
- 思考：什麼情況下應該跳過 pin 驗證？

## 選項

A) 過期時間比較運算符錯誤：使用 `<` 而非 `>`，導致未過期的 pin 被跳過

B) 時間單位不一致：expirationTime 是 seconds，currentTimeMillis() 是 milliseconds

C) 比較時使用了錯誤的時間來源：使用 SystemClock.elapsedRealtime() 而非 System.currentTimeMillis()

D) 過期檢查位置錯誤：應該在 checkServerTrusted() 而非 checkPins() 中檢查
