# Q006: IntentService START_REDELIVER_INTENT 設定失效

## CTS 測試失敗現象

執行 `android.app.cts.IntentServiceTest#testRedelivery` 失敗

```
FAILURE: testRedelivery
java.lang.AssertionError: Service did not redeliver intent after process restart
    Expected onStartCommand return: START_REDELIVER_INTENT
    Actual onStartCommand return: START_NOT_STICKY
```

## 測試代碼片段

```java
public void testRedelivery() throws Throwable {
    // IntentServiceStub calls setIntentRedelivery(true) in constructor
    IntentServiceStub.setRedeliveryEnabled(true);
    
    mContext.startService(mIntent);
    
    // 驗證 onStartCommand 返回值
    int returnValue = IntentServiceStub.getOnStartCommandReturn();
    assertEquals(Service.START_REDELIVER_INTENT, returnValue);  // 失敗！
}
```

## 症狀描述

- IntentService 調用了 setIntentRedelivery(true)
- 預期 onStartCommand 返回 START_REDELIVER_INTENT
- 實際返回 START_NOT_STICKY
- 這會導致進程被殺後 Intent 不會被重新傳遞

## 你的任務

1. 分析 setIntentRedelivery() 如何影響 onStartCommand 返回值
2. 找出為什麼設定沒有生效
3. 追蹤 mRedelivery 標誌的使用
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/IntentService.java`
  - `frameworks/base/core/java/android/app/Service.java`
- 關注 `setIntentRedelivery()` 和 `onStartCommand()` 方法
- 注意條件判斷邏輯和返回值常量
- Service 基類的默認行為也需要檢查
