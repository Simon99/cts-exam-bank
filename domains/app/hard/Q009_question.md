# Q009: AccountManager 認證回調在錯誤線程執行

## CTS 測試失敗現象

執行 `android.accounts.cts.AccountManagerTest#testAuthTokenCallbackThread` 失敗

```
FAILURE: testAuthTokenCallbackThread
junit.framework.AssertionFailedError: 
    AccountManagerCallback invoked on wrong thread
    
    Expected callback thread: main (Looper@abc123)
    Actual callback thread: Binder:1234_5 
    
    Handler provided: Handler{main}
    
    java.lang.IllegalStateException: 
        Can't create handler inside thread that has not called Looper.prepare()
    
    at android.accounts.cts.AccountManagerTest.testAuthTokenCallbackThread(AccountManagerTest.java:456)
```

## 測試代碼片段

```java
@Test
public void testAuthTokenCallbackThread() throws Exception {
    final CountDownLatch latch = new CountDownLatch(1);
    final AtomicReference<Thread> callbackThread = new AtomicReference<>();
    final Handler mainHandler = new Handler(Looper.getMainLooper());
    
    AccountManagerCallback<Bundle> callback = new AccountManagerCallback<Bundle>() {
        @Override
        public void run(AccountManagerFuture<Bundle> future) {
            callbackThread.set(Thread.currentThread());
            // 驗證可以在此線程創建 Handler（意味著在有 Looper 的線程）
            new Handler();  // 這裡拋出異常
            latch.countDown();
        }
    };
    
    // 指定 callback 在 main thread 執行
    mAccountManager.getAuthToken(mAccount, AUTH_TOKEN_TYPE, null, 
        mActivity, callback, mainHandler);
    
    assertTrue("Callback not received", latch.await(30, TimeUnit.SECONDS));
    
    assertEquals("Callback should run on main thread",
        Looper.getMainLooper().getThread(), callbackThread.get());
}
```

## 症狀描述

- 請求認證 token 時指定了 Handler 來控制 callback 線程
- Callback 卻在 Binder 線程執行而非指定的 main thread
- 在 Binder 線程無法創建 Handler（沒有 Looper）
- 違反了 API 的線程約定

## 你的任務

1. 追蹤 AccountManager 的認證請求和回調流程
2. 分析 Handler 參數是如何被使用的
3. 找出 callback 被投遞到錯誤線程的原因
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/accounts/AccountManager.java`
  - `frameworks/base/services/core/java/com/android/server/accounts/AccountManagerService.java`
  - `frameworks/base/core/java/android/accounts/IAccountManagerResponse.aidl`
- 關注 `AmsTask` 內部類的 `Response` 處理
- 關注 Binder callback 到 Handler 的轉換
