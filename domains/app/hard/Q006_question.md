# Q006: JobScheduler 約束條件組合錯誤

## CTS 測試失敗現象

執行 `android.app.job.cts.JobSchedulerTest#testCombinedConstraints` 失敗

```
FAILURE: testCombinedConstraints
junit.framework.AssertionFailedError: 
    Job ran when constraints were not all satisfied
    
    Job constraints:
      - requiresCharging: true (actual: true ✓)
      - requiresDeviceIdle: true (actual: false ✗)
      - requiredNetworkType: UNMETERED (actual: METERED ✗)
    
    Expected: Job should NOT run
    Actual: Job executed
    
    at android.app.job.cts.JobSchedulerTest.testCombinedConstraints(JobSchedulerTest.java:412)
```

## 測試代碼片段

```java
@Test
public void testCombinedConstraints() throws Exception {
    final CountDownLatch latch = new CountDownLatch(1);
    
    JobInfo job = new JobInfo.Builder(JOB_ID, mServiceComponent)
        .setRequiresCharging(true)
        .setRequiresDeviceIdle(true)
        .setRequiredNetworkType(JobInfo.NETWORK_TYPE_UNMETERED)
        .build();
    
    mJobScheduler.schedule(job);
    
    // 設置部分約束滿足的狀態
    setChargingState(true);      // 充電中
    setDeviceIdleState(false);   // 非 idle（不滿足）
    setNetworkType(METERED);     // 計量網絡（不滿足）
    
    // Job 不應該執行，因為有約束未滿足
    boolean jobRan = latch.await(5, TimeUnit.SECONDS);
    assertFalse("Job should not run with unsatisfied constraints", jobRan);
}
```

## 症狀描述

- Job 設置了多個約束條件（AND 關係）
- 只有部分約束滿足時 Job 就開始執行
- 系統應該等待所有約束都滿足才執行
- 看起來約束檢查變成了 OR 關係

## 你的任務

1. 分析 JobScheduler 的約束滿足判斷邏輯
2. 追蹤約束檢查在哪些組件中進行
3. 找出導致 AND 變成 OR 的 Bug
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/StateController.java`
  - `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobStatus.java`
- 關注 `JobStatus.isConstraintsSatisfied()` 方法
- 關注各個 Controller 如何報告約束狀態
