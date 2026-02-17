# Q003: 答案解析

## 問題根因
兩個檔案中的 bug 共同導致作業優先級排序錯誤：
1. `PendingJobQueue.java` 中的比較器邏輯反轉，導致低優先級作業排在前面
2. `JobStatus.java` 的 `getEffectivePriority` 返回負值，進一步破壞排序

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/PendingJobQueue.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 1 - PendingJobQueue.java
```java
private final Comparator<JobStatus> mJobComparator = (j1, j2) -> {
    // BUG: Reversed comparison - lower priority runs first
    int priorityDiff = j1.getEffectivePriority() - j2.getEffectivePriority();
    ...
};
```

## 正確代碼 1
```java
private final Comparator<JobStatus> mJobComparator = (j1, j2) -> {
    // Priority: higher runs first (j2 - j1 for descending order)
    int priorityDiff = j2.getEffectivePriority() - j1.getEffectivePriority();
    ...
};
```

## 錯誤代碼 2 - JobStatus.java
```java
public int getEffectivePriority() {
    ...
    if (numFailures < 2) {
        // BUG: Negating priority value inverts the ordering
        return -rawPriority;
    }
    ...
}
```

## 正確代碼 2
```java
public int getEffectivePriority() {
    ...
    if (numFailures < 2) {
        return rawPriority;
    }
    ...
}
```

## 調試步驟
1. 在 `PendingJobQueue` 中添加 log：
```java
Slog.d(TAG, "Comparing jobs: " + j1.toShortString() + " (pri=" + j1.getEffectivePriority() 
        + ") vs " + j2.toShortString() + " (pri=" + j2.getEffectivePriority() + ")");
```

2. 在 `JobStatus.getEffectivePriority` 中添加 log：
```java
Slog.d(TAG, "getEffectivePriority: job=" + toShortString() 
        + ", rawPriority=" + rawPriority + ", failures=" + numFailures);
```

3. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.PendingJobQueue JobScheduler.JobStatus
```

## 修復步驟
1. 打開 `PendingJobQueue.java`，修正比較器順序為 `j2 - j1`
2. 打開 `JobStatus.java`，移除 `getEffectivePriority` 中的負號

## 測試驗證
```bash
atest android.jobscheduler.cts.JobSchedulingTest#testHigherPriorityJobRunsFirst
atest android.jobscheduler.cts.JobSchedulingTest#testPriorityOrdering
```

## 相關知識點
- Java Comparator: 返回負數表示第一個參數排在前面
- 降序排序需要 `j2 - j1`，升序排序需要 `j1 - j2`
- `PRIORITY_MAX (500) > PRIORITY_HIGH (400) > PRIORITY_DEFAULT (300) > PRIORITY_LOW (200) > PRIORITY_MIN (100)`
