# Q003: 答案解析

## 問題根因
`TimeController.java` 中評估時間延遲約束時，使用了 `<` 而不是 `<=`，導致延遲時間恰好為當前時間時，約束未被滿足。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`

## 錯誤代碼
```java
/** @return true if the job's delay constraint is satisfied */
private boolean evaluateTimingDelayConstraint(JobStatus job, long nowElapsedMillis) {
    final long jobDelayTime = job.getEarliestRunTime();
    if (jobDelayTime < nowElapsedMillis) {  // BUG: 應該是 <=
        job.setTimingDelayConstraintSatisfied(nowElapsedMillis, true);
        return true;
    }
    return false;
}
```

## 正確代碼
```java
private boolean evaluateTimingDelayConstraint(JobStatus job, long nowElapsedMillis) {
    final long jobDelayTime = job.getEarliestRunTime();
    if (jobDelayTime <= nowElapsedMillis) {
        job.setTimingDelayConstraintSatisfied(nowElapsedMillis, true);
        return true;
    }
    return false;
}
```

## 修復步驟
1. 打開 `TimeController.java`
2. 找到 `evaluateTimingDelayConstraint()` 方法
3. 將 `if (jobDelayTime < nowElapsedMillis)` 改為 `if (jobDelayTime <= nowElapsedMillis)`

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testExplicitZeroLatency
```

## 相關知識點
- TimeController 管理時間相關約束
- 邊界條件 (off-by-one) 錯誤
- 作業的 earliestRunTime 計算
