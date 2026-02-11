# Q009: Remove Vibrator State Listener Failed

## CTS Test
`android.os.cts.VibratorTest#testRemoveVibratorStateListener`

## Failure Log
```
junit.framework.AssertionFailedError: Listener still receiving callbacks after removal
Received 5 additional callbacks after removeVibratorStateListener()
expected callback count to be 0 after removal but was:<5>

at android.os.cts.VibratorTest.testRemoveVibratorStateListener(VibratorTest.java:312)
```

## 現象描述
呼叫 `removeVibratorStateListener()` 後，監聽器仍繼續收到回呼。
測試新增監聽器、觸發振動、移除監聽器、再觸發振動，
但監聽器在移除後仍收到後續的狀態變更通知。

## 提示
- 檢查監聽器的移除邏輯
- 注意集合操作是否正確
- 可能使用了錯誤的方法（add vs remove）
