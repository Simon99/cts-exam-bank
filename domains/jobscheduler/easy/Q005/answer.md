# Q005: 答案解析

## 問題根因
`TimeController.java` 中 `maybeStopTrackingJobLocked()` 方法沒有正確從追蹤列表中移除作業。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`

## 錯誤代碼
```java
@Override
public void maybeStopTrackingJobLocked(JobStatus job, JobStatus incomingJob) {
    if (job.clearTrackingController(JobStatus.TRACKING_TIME)) {
        // BUG: 忘記從 mTrackedJobs 中移除作業
        // mTrackedJobs.remove(job);  // 這行被註解掉或缺失
        checkExpiredDelaysAndResetAlarm();
        checkExpiredDeadlinesAndResetAlarm();
    }
}
```

## 正確代碼
```java
@Override
public void maybeStopTrackingJobLocked(JobStatus job, JobStatus incomingJob) {
    if (job.clearTrackingController(JobStatus.TRACKING_TIME)) {
        if (mTrackedJobs.remove(job)) {
            checkExpiredDelaysAndResetAlarm();
            checkExpiredDeadlinesAndResetAlarm();
        }
    }
}
```

## 修復步驟
1. 打開 `TimeController.java`
2. 找到 `maybeStopTrackingJobLocked()` 方法
3. 確保在清除追蹤控制器後，也從 `mTrackedJobs` 列表中移除作業

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testCancel
```

## 相關知識點
- 作業取消時需要從所有相關的追蹤結構中移除
- `clearTrackingController()` 只清除作業自身的追蹤標記
- 控制器需要維護自己的追蹤列表
