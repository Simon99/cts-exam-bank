# Q009 Answer: Get Private Key from KeyChain

## 正確答案
**B) LINE A 被註解導致 latch 永遠不會倒數**

## 問題根因
`CountDownLatch` 用於同步等待非同步回呼完成。當回呼觸發時，應該呼叫 
`latch.countDown()` 來通知等待的執行緒。

但 `latch.countDown()` 被註解掉了，導致：
1. `latch.await(5, TimeUnit.SECONDS)` 會等待 5 秒後超時
2. 超時後 `keyRef.get()` 可能返回 null（如果回呼還沒完成）
3. 或者返回正確的值（如果回呼在 5 秒內完成，但沒有通知）

實際上因為沒有 countDown，await 會超時返回，而此時 key 可能已設定也可能沒有。

## Bug 位置
`frameworks/base/keystore/java/android/security/KeyChain.java`

## 修復方式
```java
// 錯誤的代碼
@Override
public void onResult(PrivateKey key) {
    keyRef.set(key);
    // latch.countDown();  // BUG: 被註解掉
}

// 正確的代碼
@Override
public void onResult(PrivateKey key) {
    keyRef.set(key);
    latch.countDown();  // 通知等待的執行緒
}
```

## 選項分析
- **A) 錯誤** - bindService 會拋出異常而非返回 null
- **B) 正確** - latch 不倒數會導致超時和競態條件
- **C) 錯誤** - 使用超時是正確的做法，避免無限等待
- **D) 錯誤** - finally 清理是正確的位置

## 相關知識
- CountDownLatch 是 Java 並發同步工具
- Android KeyChain 使用 Binder IPC 進行跨進程通訊
- 非同步操作需要正確的同步機制

## 難度說明
**Medium** - 需要理解並發同步機制和 CountDownLatch 的用法。
