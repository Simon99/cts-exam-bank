# Q002: 答案解析

## 問題根因
`DeviceIdleJobsController` 在判斷是否允許作業執行時，沒有正確識別使用者發起的作業。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/DeviceIdleJobsController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/QuotaController.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`

## 錯誤代碼
```java
// DeviceIdleJobsController.java
private boolean isJobAllowedInDoze(JobStatus job) {
    // BUG: 沒有檢查 user-initiated 作業
    if (job.isRequestedExpeditedJob()) {
        return true;
    }
    // 缺少: if (job.isUserInitiatedJob()) return true;
    return mDeviceIdleWhitelistAppIds.contains(UserHandle.getAppId(job.getSourceUid()));
}

// QuotaController.java  
private boolean isWithinQuotaLocked(JobStatus job) {
    // BUG: 在 Doze 模式檢查中沒有豁免 user-initiated 作業
    if (mInDoze) {
        // 應該檢查 job.isUserInitiatedJob()
        return isJobAllowedDuringDoze(job);
    }
    // ...
}
```

## 正確代碼
```java
// DeviceIdleJobsController.java
private boolean isJobAllowedInDoze(JobStatus job) {
    // User-initiated jobs are allowed in Doze
    if (job.isUserInitiatedJob()) {
        return true;
    }
    if (job.isRequestedExpeditedJob()) {
        return true;
    }
    return mDeviceIdleWhitelistAppIds.contains(UserHandle.getAppId(job.getSourceUid()));
}
```

## 調試步驟
1. 添加 log 追蹤 Doze 狀態和作業類型：
```java
Slog.d(TAG, "isJobAllowedInDoze: " + job.toShortString()
        + " userInitiated=" + job.isUserInitiatedJob()
        + " expedited=" + job.isRequestedExpeditedJob()
        + " inDoze=" + mInDoze);
```

2. 追蹤 `DeviceIdleController` 的 Doze 狀態變化

3. 檢查多個 Controller 的約束評估順序

## 測試驗證
```bash
atest android.jobscheduler.cts.ConnectivityConstraintTest#testUserInitiatedJobExecutes_DozeOn
atest android.jobscheduler.cts.ConnectivityConstraintTest#testUserInitiatedJobExecutes_BatterySaverOn
```

## 相關知識點
- User-Initiated Jobs (UIJ) 是使用者明確觸發的高優先級作業
- UIJ 應該繞過 Doze 和 Battery Saver 限制
- `DeviceIdleJobsController` 控制 Doze 模式下的作業執行
- 多個 Controller 可能同時阻止作業執行
