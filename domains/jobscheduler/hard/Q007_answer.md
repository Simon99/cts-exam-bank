# Q007: 答案解析

## 問題根因
RESTRICTED bucket 的 parole session 處理涉及三個檔案的交互錯誤：
1. `QuotaController` 沒有正確檢查 parole session 配額
2. `JobSchedulerService.isUidTempWhitelisted()` 總是返回 false
3. `JobStatus.getEffectiveStandbyBucket()` 沒有為有資格的應用提供 parole

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/QuotaController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/JobSchedulerService.java`
3. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼 - QuotaController.java
```java
if (standbyBucket == RESTRICTED_INDEX) {
    // BUG: 直接返回 false，忽略 parole session
    return false;
}
```

## 錯誤代碼 - JobSchedulerService.java
```java
public boolean isUidTempWhitelisted(int uid) {
    // BUG: 總是返回 false，缺少實際檢查
    return false;
}
```

## 錯誤代碼 - JobStatus.java
```java
public int getEffectiveStandbyBucket() {
    // BUG: RESTRICTED 時沒有檢查是否有 parole 資格
    if (mEffectiveBucket == RESTRICTED_INDEX) {
        return RESTRICTED_INDEX;  // 缺少 parole 檢查
    }
    return mEffectiveBucket;
}
```

## 正確代碼
### QuotaController.java
```java
if (standbyBucket == RESTRICTED_INDEX) {
    return isWithinRestrictedQuotaLocked(jobStatus);  // 檢查 parole
}
```

### JobSchedulerService.java
```java
public boolean isUidTempWhitelisted(int uid) {
    if (ArrayUtils.contains(mTempWhitelistedAppIds, UserHandle.getAppId(uid))) {
        return true;
    }
    return mDeviceIdleMode && mPowerSaveWhitelistTempAppIds.contains(uid);
}
```

### JobStatus.java
```java
public int getEffectiveStandbyBucket() {
    if (shouldTreatAsUserInitiatedJob() || shouldTreatAsExpeditedJob()) {
        return ACTIVE_INDEX;
    }
    return mEffectiveBucket;
}
```

## 調試步驟
1. 先檢查 `isUidTempWhitelisted()` 是否被正確調用
2. 驗證 `getEffectiveStandbyBucket()` 對 EJ/UIJ 的處理
3. 在 `isWithinQuotaLocked()` 添加 log：
```java
Slog.d(TAG, "isWithinQuotaLocked: " + jobStatus.toShortString()
        + " bucket=" + standbyBucket
        + " tempWhitelisted=" + mService.isUidTempWhitelisted(uid));
```

## 測試驗證
```bash
atest android.jobscheduler.cts.JobThrottlingTest#testJobsInRestrictedBucket_ParoleSession
```

## 相關知識點
- RESTRICTED bucket 每天有一次 parole session
- Temp whitelist 允許應用暫時繞過某些限制
- EJ 和 UIJ 應該被視為 ACTIVE bucket 來繞過配額限制
- 多層次的配額檢查需要跨檔案追蹤
