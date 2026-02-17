# Q006: 答案解析

## 問題根因
兩個檔案中的 bug 共同導致命名空間作業隔離失敗：
1. `JobSchedulerService.java` 在獲取作業列表時沒有過濾命名空間
2. `JobStore.java` 的 `forEachJob(uid, functor)` 忽略了 uid 參數

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobStore.java`

## 錯誤代碼 1 - JobSchedulerService.java
```java
mJobs.forEachJob(uid, (job) -> {
    // BUG: 沒有過濾 namespace
    jobs.add(job.getJob());
});
```

## 正確代碼 1
```java
final String namespace = mNamespace;
mJobs.forEachJob(uid, (job) -> {
    // Filter by namespace
    if (Objects.equals(namespace, job.getNamespace())) {
        jobs.add(job.getJob());
    }
});
```

## 錯誤代碼 2 - JobStore.java
```java
public void forEachJob(int uid, Consumer<JobStatus> functor) {
    // BUG: 忽略 uid 參數，遍歷所有作業
    mJobSet.forEachJob(null, functor);
}
```

## 正確代碼 2
```java
public void forEachJob(int uid, Consumer<JobStatus> functor) {
    mJobSet.forEachJob(uid, functor);
}
```

## 調試步驟
1. 在 `JobSchedulerService` 中添加 log：
```java
mJobs.forEachJob(uid, (job) -> {
    Slog.d(TAG, "forEachJob: job=" + job.toShortString() 
            + ", namespace=" + job.getNamespace() 
            + ", expectedNs=" + mNamespace);
    jobs.add(job.getJob());
});
```

2. 在 `JobStore.forEachJob` 中添加 log：
```java
public void forEachJob(int uid, Consumer<JobStatus> functor) {
    Slog.d(TAG, "forEachJob called with uid=" + uid);
    mJobSet.forEachJob(uid, functor);
}
```

3. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.Service JobScheduler.JobStore
```

## 修復步驟
1. 打開 `JobSchedulerService.java`，在 lambda 中添加 namespace 過濾
2. 打開 `JobStore.java`，將 `forEachJob(int uid, ...)` 改為正確調用帶 uid 參數的方法

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testNamespace_schedule
atest android.jobscheduler.cts.JobSchedulingTest#testNamespace_cancel
```

## 相關知識點
- 命名空間 (namespace) 用於隔離不同來源的作業
- `forEachJob(uid, functor)` 應該只遍歷指定 uid 的作業
- 多層過濾：先按 uid 過濾，再按 namespace 過濾
