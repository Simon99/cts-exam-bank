# Q006: 答案解析

## 問題根因
熱限流在 MODERATE 級別時對 EJ（加急作業）處理異常，涉及三個檔案的交互問題：
1. `ThermalStatusRestriction` 缺少 EJ 特殊處理邏輯
2. `JobSchedulerService.isJobInOvertimeLocked()` 比較運算符錯誤
3. `JobStatus.shouldTreatAsExpeditedJob()` 總是返回 false

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/restrictions/ThermalStatusRestriction.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 - ThermalStatusRestriction.java
```java
@Override
public boolean isJobRestricted(JobStatus job) {
    if (mThermalStatus >= UPPER_THRESHOLD) {
        return true;
    }
    if (mThermalStatus >= HIGHER_PRIORITY_THRESHOLD) {
        if (job.shouldTreatAsUserInitiatedJob()) {
            return false;
        }
        // BUG: 缺少 EJ 的特殊處理
        if (priority == JobInfo.PRIORITY_HIGH) {
            return !mService.isCurrentlyRunningLocked(job)
                    || mService.isJobInOvertimeLocked(job);
        }
        return true;  // EJ 被當作普通作業處理
    }
}
```

## 錯誤代碼 - JobSchedulerService.java
```java
public boolean isJobInOvertimeLocked(JobStatus job) {
    final JobServiceContext jsc = getRunningJobServiceContextLocked(job);
    if (jsc == null) return false;
    // BUG: 使用 > 而非 <，導致邏輯反轉
    return jsc.getExecutionStartTimeElapsed() + getMaxExecutionTimeMs(job)
            > sElapsedRealtimeClock.millis();  // 應該用 <
}
```

## 錯誤代碼 - JobStatus.java
```java
public boolean shouldTreatAsExpeditedJob() {
    // BUG: 總是返回 false
    return false;
}
```

## 正確代碼
### ThermalStatusRestriction.java
```java
if (job.shouldTreatAsExpeditedJob()) {
    return job.getNumPreviousAttempts() > 0
            || (mService.isCurrentlyRunningLocked(job)
                    && mService.isJobInOvertimeLocked(job));
}
```

### JobSchedulerService.java
```java
return jsc.getExecutionStartTimeElapsed() + getMaxExecutionTimeMs(job) 
        < sElapsedRealtimeClock.millis();
```

### JobStatus.java
```java
public boolean shouldTreatAsExpeditedJob() {
    return (getFlags() & JobInfo.FLAG_EXPEDITED) != 0
            && !startedAsRegularJob
            && (startedAsExpeditedJob || !hasExpeditedQuotaExhausted());
}
```

## 調試步驟
1. 先檢查 `JobStatus.shouldTreatAsExpeditedJob()` 是否正確識別 EJ
2. 驗證 `isJobInOvertimeLocked()` 的返回值是否符合預期
3. 在 `ThermalStatusRestriction.isJobRestricted()` 添加 log：
```java
Slog.d(TAG, "isJobRestricted: " + job.toShortString()
        + " thermalStatus=" + mThermalStatus
        + " isEJ=" + job.shouldTreatAsExpeditedJob()
        + " inOvertime=" + mService.isJobInOvertimeLocked(job));
```

## 測試驗證
```bash
atest android.jobscheduler.cts.JobThrottlingTest#testBackgroundEJsThermal
```

## 相關知識點
- Android 熱限流分為多個級別：NONE, LIGHT, MODERATE, SEVERE, CRITICAL
- EJ 在 MODERATE 級別應該有條件地被允許執行
- `isJobInOvertimeLocked()` 檢查作業是否超過最大執行時間
- 多層次的條件判斷需要跨檔案追蹤呼叫鏈
