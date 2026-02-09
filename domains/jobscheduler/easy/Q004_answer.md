# Q004: 答案解析

## 問題根因
`BatteryController.java` 中設定電池不低約束時，傳遞了錯誤的參數。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BatteryController.java`

## 錯誤代碼
```java
@Override
public void maybeStartTrackingJobLocked(JobStatus taskStatus, JobStatus lastJob) {
    if (taskStatus.hasPowerConstraint()) {
        // ... 充電約束處理 ...
        
        // BUG: 傳入了 !mService.isBatteryNotLow() 而不是 mService.isBatteryNotLow()
        taskStatus.setBatteryNotLowConstraintSatisfied(nowElapsed, !mService.isBatteryNotLow());
    }
}
```

## 正確代碼
```java
taskStatus.setBatteryNotLowConstraintSatisfied(nowElapsed, mService.isBatteryNotLow());
```

## 修復步驟
1. 打開 `BatteryController.java`
2. 找到 `maybeStartTrackingJobLocked()` 方法
3. 找到 `setBatteryNotLowConstraintSatisfied` 調用
4. 移除參數中的 `!` 取反操作

## 測試驗證
```bash
atest android.jobscheduler.cts.BatteryConstraintTest#testBatteryNotLowConstraintExecutes_withPower
atest android.jobscheduler.cts.BatteryConstraintTest#testBatteryNotLowConstraintExecutes_withoutPower
```

## 相關知識點
- 電池不低約束與充電約束是獨立的約束條件
- `isBatteryNotLow()` 返回 true 表示電量不低
- 約束滿足條件應該直接傳遞狀態值，不需要取反
