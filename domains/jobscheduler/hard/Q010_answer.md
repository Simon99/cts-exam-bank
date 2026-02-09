# Q010: 答案解析

## 問題根因
優先級排序涉及三個檔案的交互錯誤：
1. `PendingJobQueue` 比較器使用錯誤的排序方向
2. `JobConcurrencyManager` 沒有在約束變化後重新排序
3. `JobStatus.getEffectivePriority()` 沒有為 UIJ/EJ 提升優先級

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/PendingJobQueue.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobConcurrencyManager.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 - PendingJobQueue.java
```java
private static final Comparator<JobStatus> sJobComparator = (job1, job2) -> {
    final int priority1 = job1.getEffectivePriority();
    final int priority2 = job2.getEffectivePriority();
    // BUG: 比較方向錯誤，升序排列
    return Integer.compare(priority1, priority2);  // 應該是 priority2, priority1
};
```

## 錯誤代碼 - JobConcurrencyManager.java
```java
// BUG: 沒有在約束變化後重新排序
JobStatus job = mPendingJobs.poll();  // 可能取到錯誤的作業
```

## 錯誤代碼 - JobStatus.java
```java
public int getEffectivePriority() {
    // BUG: 直接返回原始優先級，沒有為 UIJ/EJ 提升
    return mJob.getPriority();  // 缺少 UIJ/EJ 檢查
}

public int getBias() {
    // BUG: 總是返回 0
    return 0;  // 應該返回計算的 bias
}
```

## 正確代碼
### PendingJobQueue.java
```java
if (priority1 != priority2) {
    return Integer.compare(priority2, priority1);  // 降序排列
}
final int bias1 = job1.getBias();
final int bias2 = job2.getBias();
if (bias1 != bias2) {
    return Integer.compare(bias2, bias1);
}
```

### JobStatus.java
```java
public int getEffectivePriority() {
    if (shouldTreatAsUserInitiatedJob()) {
        return JobInfo.PRIORITY_MAX;
    }
    if (shouldTreatAsExpeditedJob()) {
        return Math.max(mJob.getPriority(), JobInfo.PRIORITY_DEFAULT);
    }
    return mJob.getPriority();
}

public int getBias() {
    if (mBias != 0) {
        return mBias;
    }
    return mJobSchedulerService.getUidBias(getSourceUid());
}
```

## 調試步驟
1. 先檢查 `getEffectivePriority()` 是否正確提升 UIJ/EJ 的優先級
2. 驗證 `getBias()` 是否返回正確的 bias 值
3. 在比較器中添加 log 追蹤排序結果

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testHigherPriorityJobRunsFirst
```

## 相關知識點
- JobInfo 優先級：PRIORITY_MIN(100) < PRIORITY_LOW(200) < PRIORITY_DEFAULT(300) < PRIORITY_HIGH(400)
- UIJ 應該有 PRIORITY_MAX 的有效優先級
- Bias 來自 UID 的前台狀態
- 優先級比較必須是降序（高優先級先執行）
