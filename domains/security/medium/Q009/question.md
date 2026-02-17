# Q009: Get Private Key from KeyChain

## CTS Test
`android.security.cts.KeyChainTest#testGetPrivateKey`

## Failure Log
```
java.lang.SecurityException: 
Failed to retrieve private key
KeyChain.getPrivateKey() returned null for valid alias

at android.security.cts.KeyChainTest.testGetPrivateKey(KeyChainTest.java:145)
```

## 現象描述
CTS 測試報告無法從 KeyChain 取得私鑰。使用有效的別名呼叫 getPrivateKey() 返回 null。

## 提示
- getPrivateKey() 需要正確的上下文和別名
- 需要處理非同步回呼
- 問題出在執行緒或時序處理

## 問題
根據以下程式碼片段，哪個選項最可能導致此 CTS 失敗？

```java
// KeyChain.java
public static PrivateKey getPrivateKey(@NonNull Context context, 
        @NonNull String alias) throws KeyChainException, InterruptedException {
    
    if (context == null || alias == null) {
        throw new NullPointerException("context or alias is null");
    }
    
    final AtomicReference<PrivateKey> keyRef = new AtomicReference<>();
    final CountDownLatch latch = new CountDownLatch(1);
    
    KeyChainConnection connection = bindService(context);
    try {
        IKeyChainService service = connection.getService();
        service.requestPrivateKey(alias, new IKeyChainCallback.Stub() {
            @Override
            public void onResult(PrivateKey key) {
                keyRef.set(key);
                // latch.countDown();  // LINE A - 被註解掉了
            }
        });
        
        latch.await(5, TimeUnit.SECONDS);  // LINE B
        return keyRef.get();
    } finally {
        connection.close();
    }
}
```

A) bindService() 可能返回 null
B) LINE A 被註解導致 latch 永遠不會倒數
C) LINE B 應該使用 await() 而非 await(timeout)
D) 應該在 finally 之前返回
