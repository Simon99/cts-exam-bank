# Q001: 答案解析

## 問題根因
加急作業的網絡約束檢查沒有正確考慮應用的前/背景狀態和 Data Saver 設定的組合。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/ConnectivityController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BackgroundJobsController.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`

## 錯誤代碼
```java
// ConnectivityController.java
private boolean isNetworkAvailableForJob(JobStatus job) {
    // BUG: 對加急作業無條件跳過 Data Saver 檢查
    if (job.isRequestedExpeditedJob()) {
        return true;  // 錯誤：沒有檢查前/背景狀態
    }
    // ... 正常檢查 ...
}

// 或在 BackgroundJobsController.java 中
private boolean shouldBypassDataSaver(JobStatus job) {
    // BUG: 沒有區分前景和背景加急作業
    return job.isRequestedExpeditedJob();  // 應該也檢查 procState
}
```

## 正確代碼
```java
private boolean isNetworkAvailableForJob(JobStatus job) {
    // 只有前景加急作業可以繞過 Data Saver
    if (job.isRequestedExpeditedJob() && isJobInForeground(job)) {
        return true;
    }
    // 背景加急作業需要遵循 Data Saver 規則
    if (mDataSaverEnabled && !isJobInForeground(job)) {
        return false;
    }
    // ... 其他檢查 ...
}
```

## 調試步驟
1. 在 `ConnectivityController` 添加 log：
```java
Slog.d(TAG, "isNetworkAvailableForJob: " + job.toShortString()
        + " expedited=" + job.isRequestedExpeditedJob()
        + " foreground=" + isJobInForeground(job)
        + " dataSaver=" + mDataSaverEnabled);
```

2. 追蹤 `BackgroundJobsController` 的約束判斷

3. 檢查 `JobSchedulerService.isJobReady()` 中的多層過濾

## 測試驗證
```bash
atest android.jobscheduler.cts.ConnectivityConstraintTest#testBgExpeditedJobDoesNotBypassDataSaver
atest android.jobscheduler.cts.ConnectivityConstraintTest#testFgExpeditedJobBypassesDataSaver
```

## 相關知識點
- Data Saver 模式限制背景網絡訪問
- 前景加急作業有更高的網絡優先權
- 多個 Controller 共同決定作業是否可以執行
- 前景/背景狀態通過 procState 和 UID bias 判斷
