# Q003: 答案解析

## 問題根因
多重防火牆檢查的組合邏輯錯誤，當其中一個條件允許時就放行，而不是要求所有條件都允許。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/QuotaController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BackgroundJobsController.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/ConnectivityController.java`

## 錯誤代碼
```java
// JobSchedulerService.java 或相關判斷邏輯
private boolean canJobBypassRestrictions(JobStatus job) {
    // BUG: 使用 OR 而不是 AND，任一條件通過就放行
    return canBypassBatterySaver(job) 
            || canBypassDataSaver(job)  // 應該是 &&
            || canBypassQuota(job);
}

// 或在個別 Controller 中
private boolean isExemptFromFirewalls(JobStatus job) {
    if (job.isRequestedExpeditedJob()) {
        // BUG: 沒有檢查 Data Saver 是否啟用
        return !mDataSaverEnabled || isInForeground(job);  
    }
    return false;
}
```

## 正確代碼
```java
private boolean canJobBypassRestrictions(JobStatus job) {
    // 所有防火牆都必須允許
    return canBypassBatterySaver(job) 
            && canBypassDataSaver(job) 
            && canBypassQuota(job);
}
```

## 調試步驟
1. 添加 log 追蹤各個防火牆狀態：
```java
Slog.d(TAG, "Firewall check for " + job.toShortString()
        + " batterySaver=" + canBypassBatterySaver(job)
        + " dataSaver=" + canBypassDataSaver(job)
        + " quota=" + canBypassQuota(job)
        + " standbyBucket=" + getStandbyBucket(job));
```

2. 逐個禁用防火牆測試，找出繞過的路徑

## 測試驗證
```bash
atest android.jobscheduler.cts.ConnectivityConstraintTest#testExpeditedJobDoesNotBypassSimultaneousFirewalls_withDataSaver
atest android.jobscheduler.cts.ConnectivityConstraintTest#testExpeditedJobBypassesSimultaneousFirewalls_noDataSaver
```

## 相關知識點
- 多個 Controller 形成多層防禦
- Data Saver 是最嚴格的限制之一
- Standby bucket 影響配額分配
- 加急作業可以繞過某些限制，但不是全部
