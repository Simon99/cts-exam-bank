# Q010: 答案解析

## 問題根因
配額檢查邏輯中使用了錯誤的比較運算符，導致提前觸發配額限制。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`

## 錯誤代碼
```java
// 在檢查排程配額時
private int checkSchedulingQuota(int callingUid, String callingPackage, JobInfo job) {
    // ...
    final int currentCount = mQuotaTracker.getCurrentCount(callingUid);
    final int maxQuota = mConstants.API_QUOTA_SCHEDULE_COUNT;
    
    // BUG: 使用 >= 而不是 >，導致在剛好達到配額時就拒絕
    if (currentCount >= maxQuota) {
        return JobScheduler.RESULT_FAILURE;
    }
    return JobScheduler.RESULT_SUCCESS;
}
```

## 正確代碼
```java
private int checkSchedulingQuota(int callingUid, String callingPackage, JobInfo job) {
    // ...
    final int currentCount = mQuotaTracker.getCurrentCount(callingUid);
    final int maxQuota = mConstants.API_QUOTA_SCHEDULE_COUNT;
    
    // 使用 > 允許排程到剛好達到配額
    if (currentCount > maxQuota) {
        return JobScheduler.RESULT_FAILURE;
    }
    return JobScheduler.RESULT_SUCCESS;
}
```

## 修復步驟
1. 打開 `JobSchedulerService.java`
2. 找到排程配額檢查的邏輯
3. 將 `>=` 改為 `>`，或將配額值調整為正確的閾值

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testMinSuccessfulSchedulingQuota
```

## 相關知識點
- JobScheduler API 配額限制機制
- 持久化作業 vs 非持久化作業的配額差異
- 邊界條件 (off-by-one) 錯誤
