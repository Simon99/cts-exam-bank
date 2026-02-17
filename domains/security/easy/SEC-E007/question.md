# SEC-E007: Device Locked 狀態返回錯誤

## CTS Test
`android.keystore.cts.RootOfTrustTest#testDeviceLocked`

## Failure Log
```
junit.framework.AssertionFailedError: Device locked state incorrect
Expected: true (device is locked)
Actual: false

at android.keystore.cts.RootOfTrustTest.testDeviceLocked(RootOfTrustTest.java:89)
```

## 現象描述
CTS 測試報告在解析 Root of Trust 時，
即使設備處於鎖定狀態，`isDeviceLocked()` 仍返回 false。
這可能導致安全策略的錯誤判斷。

## 提示
- Root of Trust 包含設備安全啟動的資訊
- Device Locked 表示 bootloader 是否已鎖定
- 問題可能在於返回值的處理

## 選項

A) `isDeviceLocked()` 中將欄位名稱拼寫錯誤

B) `isDeviceLocked()` 硬編碼返回 `false`

C) 解析 deviceLocked 時使用了錯誤的 byte 位置

D) `isDeviceLocked()` 返回了 `verifiedBootState` 而非 `deviceLocked`
