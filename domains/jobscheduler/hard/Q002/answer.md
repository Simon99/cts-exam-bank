# Q002: 答案解析

## 正確答案
**B. `JobStatus.canRunInDoze()` 缺少對 User-Initiated Job 的豁免檢查**

## 問題根因
`JobStatus.canRunInDoze()` 方法決定作業是否可以在 Doze 模式下執行。該方法應該對 User-Initiated Job 進行豁免，但豁免檢查被遺漏了。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼
```java
public boolean canRunInDoze() {
    return appHasDozeExemption
            || (getFlags() & JobInfo.FLAG_WILL_BE_FOREGROUND) != 0
            // BUG: 缺少 shouldTreatAsUserInitiatedJob() 檢查
            // EJs can't run in Doze if we explicitly require that the device is not Dozing.
            || ((shouldTreatAsExpeditedJob() || startedAsExpeditedJob)
                    && (mDynamicConstraints & CONSTRAINT_DEVICE_NOT_DOZING) == 0);
}
```

## 正確代碼
```java
public boolean canRunInDoze() {
    return appHasDozeExemption
            || (getFlags() & JobInfo.FLAG_WILL_BE_FOREGROUND) != 0
            || shouldTreatAsUserInitiatedJob()  // User-initiated jobs are allowed in Doze
            // EJs can't run in Doze if we explicitly require that the device is not Dozing.
            || ((shouldTreatAsExpeditedJob() || startedAsExpeditedJob)
                    && (mDynamicConstraints & CONSTRAINT_DEVICE_NOT_DOZING) == 0);
}
```

## 選項分析

**A. `DeviceIdleJobsController` 的白名單過濾邏輯錯誤**
- 錯誤：`DeviceIdleJobsController` 負責追蹤 Doze 狀態並更新 constraint，但最終是否允許執行是由 `JobStatus.canRunInDoze()` 決定的。

**B. `JobStatus.canRunInDoze()` 缺少對 User-Initiated Job 的豁免檢查** ✓
- 正確：這是 bug 的實際位置。方法中有對 `appHasDozeExemption`、`FLAG_WILL_BE_FOREGROUND` 和 Expedited Job 的檢查，但缺少對 `shouldTreatAsUserInitiatedJob()` 的檢查。

**C. `QuotaController` 在 Doze 模式下的配額計算錯誤**
- 錯誤：`QuotaController` 處理配額限制，與 Doze 模式的豁免邏輯是分開的。

**D. `JobSchedulerService.isReadyToBeExecutedLocked()` 未正確處理 Doze 約束**
- 錯誤：`isReadyToBeExecutedLocked()` 檢查 `job.isReady()`，而 `isReady()` 依賴 `mReadyNotDozing`，這個值由 `canRunInDoze()` 計算。問題的根源在 `canRunInDoze()`。

## 調試步驟
1. 在 `JobStatus.canRunInDoze()` 添加日誌：
```java
Slog.d(TAG, "canRunInDoze: " + toShortString()
        + " appHasDozeExemption=" + appHasDozeExemption
        + " userInitiated=" + shouldTreatAsUserInitiatedJob()
        + " expedited=" + shouldTreatAsExpeditedJob());
```

2. 追蹤 `mReadyNotDozing` 的值變化

3. 比較 `canRunInDoze()` 和 `canRunInBatterySaver()` 的實作

## 測試驗證
```bash
atest android.jobscheduler.cts.UserInitiatedJobTest#testUserInitiatedJobExecutes_DozeOn
atest android.jobscheduler.cts.UserInitiatedJobTest
```

## 相關知識點
- **User-Initiated Jobs (UIJ)** 是使用者明確觸發的高優先級作業（如「立即同步」按鈕）
- UIJ 應該繞過 Doze 和 Battery Saver 限制
- `canRunInDoze()` 和 `canRunInBatterySaver()` 是決定作業在省電模式下能否執行的關鍵方法
- Expedited Jobs (EJ) 也有類似的豁免邏輯，但條件略有不同
