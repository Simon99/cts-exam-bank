# Q004: 答案解析

## 問題根因
`FlexibilityController` 沒有正確接收其他 Controller 的約束狀態更新通知。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/FlexibilityController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BatteryController.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`

## 錯誤代碼
```java
// BatteryController.java
private void maybeReportNewChargingStateLocked() {
    // ... 更新充電狀態 ...
    
    // BUG: 忘記通知 FlexibilityController
    // mFlexibilityController.setConstraintSatisfied(
    //         JobStatus.CONSTRAINT_CHARGING, mService.isBatteryCharging(), nowElapsed);
}

// FlexibilityController.java
public void setConstraintSatisfied(int constraint, boolean satisfied, long nowElapsed) {
    // BUG: 沒有正確更新內部狀態或通知作業
    mSatisfiedConstraints = satisfied 
            ? (mSatisfiedConstraints | constraint)
            : (mSatisfiedConstraints & ~constraint);
    // 缺少: updateTrackedJobsLocked(nowElapsed);
}
```

## 正確代碼
```java
// BatteryController.java
private void maybeReportNewChargingStateLocked() {
    // ... 更新充電狀態 ...
    
    mFlexibilityController.setConstraintSatisfied(
            JobStatus.CONSTRAINT_CHARGING, mService.isBatteryCharging(), nowElapsed);
    mFlexibilityController.setConstraintSatisfied(
            JobStatus.CONSTRAINT_BATTERY_NOT_LOW, batteryNotLow, nowElapsed);
}
```

## 調試步驟
1. 在各 Controller 中添加約束變化 log
2. 追蹤 `setConstraintSatisfied()` 調用鏈
3. 檢查約束滿足度分數計算

## 測試驗證
```bash
atest android.jobscheduler.cts.FlexibilityConstraintTest
```

## 相關知識點
- FlexibilityController 是一個元控制器，協調其他約束
- 軟約束允許在某些條件不滿足時仍執行作業
- Controller 間需要正確通信以維護一致的狀態視圖
