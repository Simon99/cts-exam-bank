# Q008: 答案解析

## 問題根因
Deadline 約束評估涉及三個檔案的交互錯誤：
1. `TimeController` 使用錯誤的比較運算符（< 而非 <=）
2. `JobStatus.setDeadlineConstraintSatisfied()` 沒有正確設置時間戳
3. `JobSchedulerService.isReadyToBeExecutedLocked()` 無條件地允許有 deadline 的作業執行

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`

## 錯誤代碼 - TimeController.java
```java
private boolean evaluateDeadlineConstraint(JobStatus job, long nowElapsedMillis) {
    final long latestRunTimeElapsed = job.getLatestRunTimeElapsed();
    // BUG: 使用 < 而非 <=，導致 deadline 提前被標記為滿足
    if (latestRunTimeElapsed < nowElapsedMillis) {
        job.setDeadlineConstraintSatisfied(nowElapsedMillis, true);
        return true;
    }
}
```

## 錯誤代碼 - JobStatus.java
```java
public boolean setDeadlineConstraintSatisfied(long nowElapsed, boolean state) {
    if (state) {
        // BUG: 設置為 0 而非 nowElapsed
        mDeadlineSatisfiedAtElapsed = 0;
        return setConstraintSatisfied(CONSTRAINT_DEADLINE, nowElapsed, true);
    }
    return setConstraintSatisfied(CONSTRAINT_DEADLINE, nowElapsed, false);
}
```

## 錯誤代碼 - JobSchedulerService.java
```java
private boolean isReadyToBeExecutedLocked(JobStatus job) {
    // BUG: 有 deadline 就返回 true，不檢查是否真的到達
    if (job.hasDeadlineConstraint()) {
        return true;
    }
    return job.isConstraintsSatisfied();
}
```

## 正確代碼
### TimeController.java
```java
if (latestRunTimeElapsed <= nowElapsedMillis) {  // <= 而非 <
    job.setDeadlineConstraintSatisfied(nowElapsedMillis, true);
    return true;
}
```

### JobStatus.java
```java
if (state) {
    mDeadlineSatisfiedAtElapsed = nowElapsed;  // 正確保存時間
    return setConstraintSatisfied(CONSTRAINT_DEADLINE, nowElapsed, state);
}
```

### JobSchedulerService.java
```java
if (!job.isReady()) {
    return false;
}
if (job.hasDeadlineConstraint() && job.isConstraintSatisfied(CONSTRAINT_DEADLINE)) {
    return true;  // 只有當 deadline 真的滿足時才返回 true
}
return job.isConstraintsSatisfied();
```

## 調試步驟
1. 先檢查 `evaluateDeadlineConstraint()` 的比較邏輯
2. 驗證 `setDeadlineConstraintSatisfied()` 是否正確記錄時間
3. 追蹤 `isReadyToBeExecutedLocked()` 的判斷邏輯

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testJobWithDeadlineDoesNotRunEarly
```

## 相關知識點
- Deadline 約束：作業必須在指定時間前完成
- `<` vs `<=` 的差異會導致 1ms 的時機誤差
- 多個約束需要同時滿足，除非 deadline 已到
