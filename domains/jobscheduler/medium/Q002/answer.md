# Q002: 答案解析

## 問題根因
兩個檔案中的 bug 共同導致充電狀態變化時作業未被正確停止：
1. `BatteryController.java` 忘記將狀態改變的作業加入 `mChangedJobs` 列表
2. `JobStatus.java` 的 `setChargingConstraintSatisfied` 永遠返回 false，掩蓋了實際的狀態變化

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/BatteryController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 1 - BatteryController.java
```java
} else if (ts.setChargingConstraintSatisfied(nowElapsed, stablePower)) {
    // BUG: forgot to add to changed jobs when constraint changes
}
```

## 正確代碼 1
```java
} else if (ts.setChargingConstraintSatisfied(nowElapsed, stablePower)) {
    mChangedJobs.add(ts);
}
```

## 錯誤代碼 2 - JobStatus.java
```java
boolean setChargingConstraintSatisfied(final long nowElapsed, boolean state) {
    // BUG: Always returns false, masking actual state changes
    return false && setConstraintSatisfied(CONSTRAINT_CHARGING, nowElapsed, state);
}
```

## 正確代碼 2
```java
boolean setChargingConstraintSatisfied(final long nowElapsed, boolean state) {
    return setConstraintSatisfied(CONSTRAINT_CHARGING, nowElapsed, state);
}
```

## 調試步驟
1. 在 `BatteryController` 中添加 log：
```java
Slog.d(TAG, "Charging state changed for job " + ts.toShortString() 
        + ", stablePower=" + stablePower + ", constraintChanged=" + constraintChanged);
```

2. 在 `JobStatus.setChargingConstraintSatisfied` 中添加 log：
```java
boolean changed = setConstraintSatisfied(CONSTRAINT_CHARGING, nowElapsed, state);
Slog.d(TAG, "setChargingConstraintSatisfied: state=" + state + ", changed=" + changed);
return changed;
```

3. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.Battery JobScheduler.JobStatus
```

## 修復步驟
1. 打開 `BatteryController.java`，在 `setChargingConstraintSatisfied` 返回 true 時添加 `mChangedJobs.add(ts)`
2. 打開 `JobStatus.java`，移除 `false &&` 前綴，恢復正確的返回值

## 測試驗證
```bash
atest android.jobscheduler.cts.BatteryConstraintTest#testChargingConstraintFails
atest android.jobscheduler.cts.BatteryConstraintTest#testBatteryNotLowConstraintFails
```

## 相關知識點
- `setChargingConstraintSatisfied` 返回值表示約束狀態是否發生改變
- 只有狀態實際改變時才需要將作業加入 `mChangedJobs`
- `mChangedJobs` 會被用來通知 JobSchedulerService 重新評估作業
