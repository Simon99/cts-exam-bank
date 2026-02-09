# Q008: AlarmManager 精確喚醒時間飄移

## CTS 測試失敗現象

執行 `android.app.cts.AlarmManagerTest#testExactAlarmPrecision` 失敗

```
FAILURE: testExactAlarmPrecision
junit.framework.AssertionFailedError: 
    Exact alarm delivered with unacceptable delay
    
    Scheduled trigger time: 1707400000000 (12:00:00.000)
    Actual trigger time: 1707400003500 (12:00:03.500)
    Delay: 3500ms
    
    Maximum acceptable delay for setExactAndAllowWhileIdle: 500ms
    
    at android.app.cts.AlarmManagerTest.testExactAlarmPrecision(AlarmManagerTest.java:198)
```

## 測試代碼片段

```java
@Test
public void testExactAlarmPrecision() throws Exception {
    final long triggerTime = System.currentTimeMillis() + 5000;
    final AtomicLong actualTriggerTime = new AtomicLong();
    final CountDownLatch latch = new CountDownLatch(1);
    
    PendingIntent pi = createPendingIntent(new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            actualTriggerTime.set(System.currentTimeMillis());
            latch.countDown();
        }
    });
    
    // 使用精確鬧鐘，應該準時觸發
    mAlarmManager.setExactAndAllowWhileIdle(
        AlarmManager.RTC_WAKEUP, triggerTime, pi);
    
    assertTrue("Alarm not received", latch.await(30, TimeUnit.SECONDS));
    
    long delay = actualTriggerTime.get() - triggerTime;
    assertTrue("Delay " + delay + "ms exceeds 500ms limit", delay <= 500);
}
```

## 症狀描述

- 使用 `setExactAndAllowWhileIdle()` 設置精確鬧鐘
- 鬧鐘觸發時間比預期晚了 3.5 秒
- 精確鬧鐘應該在 500ms 內觸發
- 看起來被套用了不該有的電池優化延遲

## 你的任務

1. 追蹤精確鬧鐘的調度和觸發流程
2. 分析 AlarmManagerService 如何區分精確和非精確鬧鐘
3. 找出精確鬧鐘被錯誤延遲的原因
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/Alarm.java`
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmStore.java`
- 關注 `setImplLocked()` 中鬧鐘類型的處理
- 關注 batching 和 idle 優化邏輯
