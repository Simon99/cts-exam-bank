# Q001: 答案解析

## 問題根因
`BatteryController.java` 中的充電約束滿足判斷邏輯被反轉。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BatteryController.java`

## 錯誤代碼
```java
// 在 maybeStartTrackingJobLocked() 方法中
if (taskStatus.hasChargingConstraint()) {
    if (hasTopExemptionLocked(taskStatus)) {
        taskStatus.setChargingConstraintSatisfied(nowElapsed,
                !mService.isPowerConnected());  // BUG: 不應該取反
    } else {
        taskStatus.setChargingConstraintSatisfied(nowElapsed,
                !(mService.isBatteryCharging() && mService.isBatteryNotLow()));  // BUG
    }
}
```

## 正確代碼
```java
if (taskStatus.hasChargingConstraint()) {
    if (hasTopExemptionLocked(taskStatus)) {
        taskStatus.setChargingConstraintSatisfied(nowElapsed,
                mService.isPowerConnected());
    } else {
        taskStatus.setChargingConstraintSatisfied(nowElapsed,
                mService.isBatteryCharging() && mService.isBatteryNotLow());
    }
}
```

## 修復步驟
1. 打開 `BatteryController.java`
2. 找到 `maybeStartTrackingJobLocked()` 方法
3. 移除充電狀態判斷中的 `!` 取反操作

## 測試驗證
```bash
atest android.jobscheduler.cts.BatteryConstraintTest#testChargingConstraintExecutes
```

## 相關知識點
- JobScheduler 的約束 (Constraint) 機制
- BatteryController 如何追蹤電池/充電狀態
- 作業約束滿足條件的評估邏輯
