# Q010: 答案解析

## 問題根因
作業被取消時，如果設置了重新排程標記，在作業停止處理時會錯誤地重新排程。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobServiceContext.java`

## 錯誤代碼
```java
// 在 JobServiceContext 或 JobSchedulerService 中處理作業完成時
void handleJobCompletedLocked(JobStatus job, boolean reschedule) {
    removeJobFromRunningList(job);
    
    // BUG: 即使作業被取消，reschedule 標記仍然導致重新排程
    if (reschedule) {
        // 這裡應該檢查作業是否被取消
        scheduleNewJob(job);
    }
}
```

## 正確代碼
```java
void handleJobCompletedLocked(JobStatus job, boolean reschedule) {
    removeJobFromRunningList(job);
    
    // 檢查作業是否已被取消
    if (reschedule && !isCancelled(job)) {
        scheduleNewJob(job);
    }
}
```

## 調試步驟
1. 在作業完成處理添加 log：
```java
Slog.d(TAG, "handleJobCompleted: job=" + job.toShortString() 
        + " reschedule=" + reschedule + " cancelled=" + isCancelled(job));
```

2. 追蹤 `cancelAll()` 到作業移除的完整流程

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testCancel_runningJob
```

## 相關知識點
- 取消執行中的作業需要正確處理其生命週期
- `onStopJob()` 返回 true 表示作業請求重新排程
- 取消操作應該覆蓋重新排程請求
