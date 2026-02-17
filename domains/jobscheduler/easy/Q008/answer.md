# Q008: 答案解析

## 問題根因
`TimeController.java` 中評估期限約束時，沒有正確設置 deadline 約束為已滿足。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`

## 錯誤代碼
```java
/** @return true if the job's deadline constraint is satisfied */
private boolean evaluateDeadlineConstraint(JobStatus job, long nowElapsedMillis) {
    final long jobDeadline = job.getLatestRunTimeElapsed();

    if (jobDeadline <= nowElapsedMillis) {
        if (job.hasTimingDelayConstraint()) {
            job.setTimingDelayConstraintSatisfied(nowElapsedMillis, true);
        }
        // BUG: 缺少這行或第二個參數錯誤
        job.setDeadlineConstraintSatisfied(nowElapsedMillis, false);  
        return true;
    }
    return false;
}
```

## 正確代碼
```java
private boolean evaluateDeadlineConstraint(JobStatus job, long nowElapsedMillis) {
    final long jobDeadline = job.getLatestRunTimeElapsed();

    if (jobDeadline <= nowElapsedMillis) {
        if (job.hasTimingDelayConstraint()) {
            job.setTimingDelayConstraintSatisfied(nowElapsedMillis, true);
        }
        job.setDeadlineConstraintSatisfied(nowElapsedMillis, true);
        return true;
    }
    return false;
}
```

## 修復步驟
1. 打開 `TimeController.java`
2. 找到 `evaluateDeadlineConstraint()` 方法
3. 確保在期限過期時調用 `setDeadlineConstraintSatisfied(nowElapsedMillis, true)`

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testJobParameters_expiredDeadline
atest android.jobscheduler.cts.TimingConstraintsTest#testJobParameters_unexpiredDeadline
```

## 相關知識點
- Deadline 約束允許作業在期限到期時強制執行，即使其他約束未滿足
- `isOverrideDeadlineExpired()` 讓作業知道它是因為期限過期而執行的
