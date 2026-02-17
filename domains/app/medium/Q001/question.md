# Q001: IntentService Intent 處理計數錯誤

## CTS 測試失敗現象

執行 `android.app.cts.IntentServiceTest#testIntents` 失敗

```
FAILURE: testIntents
com.android.compatibility.common.util.PollingCheck$TimeoutException: 
    onHandleIntentCalled not called enough
    Condition not met after 30000ms

Expected handleIntent call count: 3
Actual handleIntent call count: 1
```

## 測試代碼片段

```java
public void testIntents() throws Throwable {
    final int value = 42;
    final int adds = 3;

    Intent addIntent = new Intent(mContext, IntentServiceStub.class);
    addIntent.setAction(IntentServiceStub.ISS_ADD);
    addIntent.putExtra(IntentServiceStub.ISS_VALUE, 42);

    for (int i = 0; i < adds; i++) {
        mContext.startService(addIntent);
    }

    // 等待 3 次 onHandleIntent 調用
    PollingCheck.check("onHandleIntentCalled not called enough", TIMEOUT_MSEC,
            () -> IntentServiceStub.getOnHandleIntentCalledCount() == adds);

    // 驗證累加結果
    PollingCheck.check("accumulator not correct", TIMEOUT_MSEC, 
            () -> IntentServiceStub.getAccumulator() == adds * value);
}
```

## 症狀描述

- 連續發送 3 個 startService Intent
- 預期 onHandleIntent 被調用 3 次
- 實際只被調用 1 次
- 後續的 Intent 似乎被丟棄了

## 你的任務

1. 分析 IntentService 處理多個 Intent 的機制
2. 找出為什麼後續 Intent 沒有被處理
3. 需要加 log 追蹤消息的發送和處理
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/core/java/android/app/IntentService.java`
  - `frameworks/base/core/java/android/os/HandlerThread.java`
- 關注 `onStart()` 方法中消息的發送
- 關注 ServiceHandler 的消息處理
- 可能涉及 HandlerThread 的 Looper 獲取時機
