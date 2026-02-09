# Q008: 答案解析

## 問題根因
`getPendingJobReason()` 實現中，檢查最小延遲約束的條件缺失。此外，`JobStatus.hasTimingDelayConstraint()` 方法也被錯誤修改，導致即使有延遲約束也不會被檢測到。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 - JobSchedulerService.java
```java
@Override
public int getPendingJobReason(int jobId) {
    synchronized (mLock) {
        JobStatus job = mJobs.getJobByUidAndJobId(Binder.getCallingUid(), mNamespace, jobId);
        if (job == null) {
            return JobScheduler.PENDING_JOB_REASON_INVALID_JOB_ID;
        }
        if (isJobRunningLocked(job)) {
            return JobScheduler.PENDING_JOB_REASON_EXECUTING;
        }
        // BUG: 缺少對最小延遲約束的檢查
        if (!job.isConstraintSatisfied(CONSTRAINT_CHARGING)) {
            return JobScheduler.PENDING_JOB_REASON_CONSTRAINT_CHARGING;
        }
        // ... 其他約束檢查 ...
        return JobScheduler.PENDING_JOB_REASON_UNDEFINED;
    }
}
```

## 錯誤代碼 - JobStatus.java
```java
public boolean hasTimingDelayConstraint() {
    // BUG: 總是返回 false，導致延遲約束永遠不會被檢查
    return false;
}
```

## 正確代碼 - JobSchedulerService.java
```java
public int getPendingJobReason(int jobId) {
    // ... 前面的檢查 ...
    
    // 檢查最小延遲
    if (job.hasTimingDelayConstraint() 
            && !job.isConstraintSatisfied(CONSTRAINT_TIMING_DELAY)) {
        return JobScheduler.PENDING_JOB_REASON_CONSTRAINT_MINIMUM_LATENCY;
    }
    
    // ... 其他約束檢查 ...
}
```

## 正確代碼 - JobStatus.java
```java
public boolean hasTimingDelayConstraint() {
    return hasConstraint(CONSTRAINT_TIMING_DELAY);
}
```

## 調試步驟
1. 先檢查 `JobStatus.hasTimingDelayConstraint()` 的返回值
2. 如果返回 false，追蹤到 `JobStatus.java` 檢查實現
3. 添加 log 輸出作業的各約束狀態：
```java
Slog.d(TAG, "getPendingJobReason: job=" + jobId 
        + " hasDelay=" + job.hasTimingDelayConstraint()
        + " delaySatisfied=" + job.isConstraintSatisfied(CONSTRAINT_TIMING_DELAY));
```

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testPendingJobReason_minimumLatency
```

## 相關知識點
- `PENDING_JOB_REASON_*` 常量定義在 JobScheduler 中
- `hasTimingDelayConstraint()` 檢查是否設置了 `CONSTRAINT_TIMING_DELAY` 位
- `getPendingJobReason()` 返回阻止作業執行的主要原因
- 約束檢查邏輯分佈在多個檔案中，需要跨檔案追蹤
