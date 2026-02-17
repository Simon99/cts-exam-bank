# Q005: 答案解析

## 問題根因
在設置加急作業的進程能力時，沒有正確考慮網絡約束。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobServiceContext.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobConcurrencyManager.java`

## 錯誤代碼
```java
// 在 JobServiceContext 或 JobConcurrencyManager 中
private int getCapabilitiesForJob(JobStatus job) {
    int capabilities = 0;
    if (job.isUserInitiated()) {
        capabilities |= PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK;
    }
    // BUG: 缺少對 expedited job 有網絡約束時的處理
    // if (job.isRequestedExpeditedJob() && job.hasConnectivityConstraint()) {
    //     capabilities |= PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK;
    // }
    return capabilities;
}
```

## 正確代碼
```java
private int getCapabilitiesForJob(JobStatus job) {
    int capabilities = 0;
    if (job.isUserInitiated()) {
        capabilities |= PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK;
    }
    // 加急作業有網絡約束時也需要網絡能力
    if (job.isRequestedExpeditedJob() && job.hasConnectivityConstraint()) {
        capabilities |= PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK;
    }
    return capabilities;
}
```

## 調試步驟
1. 在作業開始執行前添加 log：
```java
Slog.d(TAG, "Job capabilities: expedited=" + job.isRequestedExpeditedJob() 
        + " hasNetwork=" + job.hasConnectivityConstraint()
        + " caps=" + capabilities);
```

## 測試驗證
```bash
atest android.jobscheduler.cts.ExpeditedJobTest#testJobUidState_withRequiredNetwork
atest android.jobscheduler.cts.ExpeditedJobTest#testJobUidState_noRequiredNetwork
```

## 相關知識點
- 加急作業 (Expedited Jobs) 的特殊處理
- `PROCESS_CAPABILITY_POWER_RESTRICTED_NETWORK` 允許在省電模式下使用網絡
- 作業執行時的進程狀態和能力設置
