# Q003: BroadcastReceiver 有序廣播結果丟失

## CTS 測試失敗現象

執行 `android.content.cts.BroadcastReceiverTest#testOrderedBroadcastResult` 失敗

```
FAILURE: testOrderedBroadcastResult
junit.framework.AssertionFailedError: 
    Ordered broadcast result not propagated correctly
    
    Expected resultCode: 100
    Actual resultCode: -1 (RESULT_CANCELED)
    
    Expected resultData: "modified_by_receiver_2"
    Actual resultData: null
    
    at android.content.cts.BroadcastReceiverTest.testOrderedBroadcastResult(BroadcastReceiverTest.java:189)
```

## 測試代碼片段

```java
@Test
public void testOrderedBroadcastResult() throws Exception {
    final CountDownLatch latch = new CountDownLatch(1);
    final AtomicInteger resultCode = new AtomicInteger();
    final AtomicReference<String> resultData = new AtomicReference<>();
    
    // 定義結果接收器
    BroadcastReceiver resultReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            resultCode.set(getResultCode());
            resultData.set(getResultData());
            latch.countDown();
        }
    };
    
    // 發送有序廣播，初始 resultCode=0
    Intent intent = new Intent("com.test.ORDERED_BROADCAST");
    mContext.sendOrderedBroadcast(intent, null, resultReceiver, 
        null, 0, null, null);
    
    // 中間接收器會設置 resultCode=100, resultData="modified_by_receiver_2"
    assertTrue("Timeout waiting for broadcast", latch.await(10, TimeUnit.SECONDS));
    
    assertEquals(100, resultCode.get());
    assertEquals("modified_by_receiver_2", resultData.get());
}

// 中間接收器 (priority=50)
public class MiddleReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        setResultCode(100);
        setResultData("modified_by_receiver_2");
    }
}
```

## 症狀描述

- 有序廣播鏈中，中間接收器設置的 resultCode 和 resultData
- 最終結果接收器收到的是預設值（-1 和 null）
- 廣播結果在傳遞過程中丟失

## 你的任務

1. 理解有序廣播的結果傳遞機制
2. 追蹤 BroadcastQueue 中結果的存儲和傳遞
3. 找出結果丟失的原因
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/am/BroadcastQueueImpl.java`
  - `frameworks/base/services/core/java/com/android/server/am/BroadcastRecord.java`
  - `frameworks/base/core/java/android/app/LoadedApk.java`（ReceiverDispatcher）
- 關注 `BroadcastQueueImpl.finishReceiverLocked()` 方法
- 關注 `BroadcastRecord` 的結果字段更新邏輯
- ReceiverDispatcher 中結果如何回傳
