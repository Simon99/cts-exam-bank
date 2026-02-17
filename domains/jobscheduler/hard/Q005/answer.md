# Q005: 答案解析

## 問題根因
三個檔案中的 bug 共同導致加急作業在 Doze 模式下無法執行：
1. `DeviceIdleJobsController.java` 錯誤排除 EJ 且遺漏 canBypassDoze 檢查
2. `JobStatus.java` 的 `canRunInDoze()` 方法邏輯錯誤
3. `JobSchedulerService.java` 的 `onDeviceIdleStateChanged` 條件反轉

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/DeviceIdleJobsController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`

## 錯誤代碼 1 - DeviceIdleJobsController.java
```java
private boolean updateTaskStateLocked(JobStatus task, final long nowElapsed) {
    final boolean allowInIdle = ((task.getFlags()&JobInfo.FLAG_IMPORTANT_WHILE_FOREGROUND) != 0)
            && (mForegroundUids.get(task.getSourceUid()) || isTempWhitelistedLocked(task))
            && !task.isRequestedExpeditedJob();  // BUG: 錯誤排除 EJ
    final boolean whitelisted = isWhitelistedLocked(task);
    // BUG: 遺漏 canBypassDoze 檢查
    final boolean enableTask = !mDeviceIdleMode || whitelisted || allowInIdle;
    return task.setDeviceNotDozingConstraintSatisfied(nowElapsed, enableTask, whitelisted);
}
```

## 正確代碼 1
```java
private boolean updateTaskStateLocked(JobStatus task, final long nowElapsed) {
    final boolean allowInIdle = ((task.getFlags()&JobInfo.FLAG_IMPORTANT_WHILE_FOREGROUND) != 0)
            && (mForegroundUids.get(task.getSourceUid()) || isTempWhitelistedLocked(task));
    final boolean whitelisted = isWhitelistedLocked(task);
    final boolean canBypassDoze = task.canRunInDoze();
    final boolean enableTask = !mDeviceIdleMode || whitelisted || allowInIdle || canBypassDoze;
    return task.setDeviceNotDozingConstraintSatisfied(nowElapsed, enableTask, whitelisted);
}
```

## 錯誤代碼 2 - JobStatus.java
```java
public boolean canRunInDoze() {
    return appHasDozeExemption
            || (getFlags() & JobInfo.FLAG_WILL_BE_FOREGROUND) != 0
            // BUG: 遺漏 shouldTreatAsUserInitiatedJob()
            // BUG: 使用 AND 而不是 OR
            || ((shouldTreatAsExpeditedJob() && startedAsExpeditedJob)
                    && (mDynamicConstraints & CONSTRAINT_DEVICE_NOT_DOZING) == 0);
}
```

## 正確代碼 2
```java
public boolean canRunInDoze() {
    return appHasDozeExemption
            || (getFlags() & JobInfo.FLAG_WILL_BE_FOREGROUND) != 0
            || shouldTreatAsUserInitiatedJob()
            || ((shouldTreatAsExpeditedJob() || startedAsExpeditedJob)
                    && (mDynamicConstraints & CONSTRAINT_DEVICE_NOT_DOZING) == 0);
}
```

## 錯誤代碼 3 - JobSchedulerService.java
```java
public void onDeviceIdleStateChanged(boolean deviceIdle) {
    synchronized (mLock) {
        // BUG: 條件反轉，應該是 !deviceIdle
        if (deviceIdle) {
            // When coming out of idle...
            mHandler.obtainMessage(MSG_CHECK_JOB).sendToTarget();
        }
    }
}
```

## 正確代碼 3
```java
public void onDeviceIdleStateChanged(boolean deviceIdle) {
    synchronized (mLock) {
        if (!deviceIdle) {
            // When coming out of idle, allow things to start back up.
            mHandler.obtainMessage(MSG_CHECK_JOB).sendToTarget();
        }
    }
}
```

## 調試步驟
1. 在 `DeviceIdleJobsController` 中添加 log：
```java
Slog.d(TAG, "updateTaskStateLocked: job=" + task.toShortString() 
        + ", allowInIdle=" + allowInIdle + ", canBypassDoze=" + canBypassDoze 
        + ", enableTask=" + enableTask);
```

2. 在 `JobStatus.canRunInDoze` 中添加 log：
```java
Slog.d(TAG, "canRunInDoze: job=" + toShortString()
        + ", isEJ=" + shouldTreatAsExpeditedJob() + ", startedAsEJ=" + startedAsExpeditedJob);
```

3. 在 `JobSchedulerService.onDeviceIdleStateChanged` 中添加 log：
```java
Slog.d(TAG, "onDeviceIdleStateChanged: deviceIdle=" + deviceIdle);
```

4. 執行測試並查看 log：
```bash
adb logcat -s JobScheduler.DeviceIdleJobsController JobScheduler.JobStatus JobScheduler.Service
```

## 修復步驟
1. 打開 `DeviceIdleJobsController.java`：
   - 移除對 EJ 的錯誤排除
   - 添加 `canBypassDoze` 檢查
2. 打開 `JobStatus.java`：
   - 恢復 `shouldTreatAsUserInitiatedJob()` 檢查
   - 將 `&&` 改為 `||`
3. 打開 `JobSchedulerService.java`：
   - 將 `if (deviceIdle)` 改為 `if (!deviceIdle)`

## 測試驗證
```bash
atest android.jobscheduler.cts.JobThrottlingTest#testExpeditedJobBypassesDeviceIdle
atest android.jobscheduler.cts.JobThrottlingTest#testUserInitiatedJobBypassesDeviceIdle
```

## 相關知識點
- Expedited Jobs (EJ) 應該能夠繞過 Doze 模式限制
- User-Initiated Jobs (UIJ) 同樣有 Doze 豁免
- `canRunInDoze()` 檢查多種豁免條件
- 設備退出 Doze 時才需要觸發作業檢查
