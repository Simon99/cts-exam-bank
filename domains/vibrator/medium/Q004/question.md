# Q004: Add Vibrator State Listener Executor Not Used

## CTS Test
`android.os.cts.VibratorTest#testAddVibratorStateListenerWithExecutor`

## Failure Log
```
junit.framework.AssertionFailedError: Listener callback not executed on provided executor
Expected callback on TestExecutor but received on main thread
TestExecutor.execute() was never called

at android.os.cts.VibratorTest.testAddVibratorStateListenerWithExecutor(VibratorTest.java:338)
```

## 現象描述
呼叫 `addVibratorStateListener(executor, listener)` 時提供了自訂 Executor，
但回呼仍在主執行緒執行，而非透過提供的 Executor。

## 提示
- 檢查 addVibratorStateListener() 的 executor 處理
- 注意 executor 是否被正確儲存和使用
- 可能只儲存了 listener 而忽略 executor
