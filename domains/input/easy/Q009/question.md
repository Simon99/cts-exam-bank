# Q009: VelocityTracker obtain() 失敗

## CTS Test
`android.view.cts.VelocityTrackerTest#testObtain`

## Failure Log
```
java.lang.NullPointerException: Attempt to invoke method on null object reference
at android.view.cts.VelocityTrackerTest.testObtain(VelocityTrackerTest.java:52)
    velocityTracker.addMovement(event);
```

## 現象描述
CTS 測試報告 `VelocityTracker.obtain()` 回傳 null，導致後續操作產生 NullPointerException。
速度追蹤器無法正確取得。

## 提示
- 此測試檢查 VelocityTracker 的物件池機制
- `obtain()` 應該從物件池取得或建立新的 VelocityTracker
- 問題可能在於工廠方法的實作

## 選項

A) `obtain()` 中的 synchronized 區塊沒有正確釋放鎖

B) `obtain()` 中在物件池為空時回傳 null 而非建立新物件

C) `obtain()` 中直接回傳 null

D) `obtain()` 中呼叫了錯誤的建構子導致初始化失敗
