# Q009: Service 綁定狀態錯誤

## CTS 測試失敗現象

執行 `android.app.cts.IntentServiceTest#testIntentServiceLifeCycle` 失敗（bind 部分）

```
FAILURE: testIntentServiceLifeCycle
java.lang.UnsupportedOperationException: IntentService does not support binding
    at android.app.IntentService.onBind(IntentService.java:142)
```

## 測試代碼片段

```java
public void testIntentServiceLifeCycle() throws Throwable {
    // start service
    mContext.startService(mIntent);
    // ... wait ...
    assertTrue(IntentServiceStub.isOnStartCalled());

    // bind service
    ServiceConnection conn = new TestConnection();
    mContext.bindService(mIntent, conn, Context.BIND_AUTO_CREATE);
    new PollingCheck(TIMEOUT_MSEC) {
        protected boolean check() {
            return mConnected;
        }
    }.run();
    
    assertTrue(IntentServiceStub.isOnBindCalled());  // 拋出異常！
}
```

## 症狀描述

- 先 startService 成功
- 然後 bindService
- IntentService.onBind() 拋出 UnsupportedOperationException
- 導致 ServiceConnection 無法建立

## 你的任務

1. 分析 IntentService 的 onBind 實現
2. 找出為什麼 onBind 會拋出異常
3. 對比 Service 基類的 onBind 行為
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/IntentService.java`
  - `frameworks/base/core/java/android/app/Service.java`
- 關注 `onBind()` 方法
- 檢查返回值和異常處理
- IntentService 不支持 binding 是設計決策，但不應該拋異常
