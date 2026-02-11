# JobScheduler 注入點分布列表

**CTS 路徑**: `cts/tests/JobScheduler/`  
**更新時間**: 2025-02-11

## 概覽

- **總注入點數**: 78
- **按難度分布**: Easy(28) / Medium(32) / Hard(18)
- **涵蓋測試類別**:
  - TimingConstraintsTest (5 tests)
  - ConnectivityConstraintTest (20+ tests)
  - BatteryConstraintTest (10+ tests)
  - IdleConstraintTest (10+ tests)
  - StorageConstraintTest (5 tests)
  - JobThrottlingTest (30+ tests)
  - ExpeditedJobTest (10+ tests)
  - UserInitiatedJobTest (15+ tests)
  - JobWorkItemTest (15+ tests)
  - JobInfoTest (40+ tests)
  - TriggerContentTest (10+ tests)
  - FlexibilityConstraintTest (20+ tests)
  - DataTransferTest (5 tests)
  - NotificationTest (10+ tests)
  - ComponentConstraintTest
  - JobParametersTest
  - JobSchedulingTest

## 對應 AOSP 源碼路徑

```
frameworks/base/apex/jobscheduler/
├── service/java/com/android/server/job/
│   ├── JobSchedulerService.java              (6372 lines)
│   ├── JobConcurrencyManager.java
│   ├── JobStore.java
│   ├── JobServiceContext.java
│   ├── JobNotificationCoordinator.java
│   ├── PendingJobQueue.java
│   └── controllers/
│       ├── TimeController.java               (501 lines)
│       ├── ConnectivityController.java       (2403 lines)
│       ├── BatteryController.java            (282 lines)
│       ├── IdleController.java               (197 lines)
│       ├── StorageController.java            (206 lines)
│       ├── QuotaController.java              (4777 lines)
│       ├── FlexibilityController.java        (1843 lines)
│       ├── ContentObserverController.java    (571 lines)
│       ├── DeviceIdleJobsController.java     (327 lines)
│       ├── BackgroundJobsController.java     (441 lines)
│       ├── PrefetchController.java           (669 lines)
│       ├── TareController.java               (764 lines)
│       ├── ComponentController.java          (278 lines)
│       └── JobStatus.java                    (3230 lines)
└── framework/java/android/app/job/
    ├── JobInfo.java
    ├── JobParameters.java
    ├── JobScheduler.java
    ├── JobService.java
    ├── JobWorkItem.java
    └── JobServiceEngine.java
```

---

## 注入點清單

### 1. Timing Constraints (時間約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-TC-001 | TimeController.java | `evaluateDeadlineConstraint()` | ~85-95 | COND, CALC | Easy | TimingConstraintsTest#testSchedulePeriodic |
| JS-TC-002 | TimeController.java | `evaluateTimingDelayConstraint()` | ~95-105 | COND, CALC | Easy | TimingConstraintsTest#testExplicitZeroLatency |
| JS-TC-003 | TimeController.java | `maybeUpdateDeadlineAlarmLocked()` | ~200-250 | COND, STATE | Medium | TimingConstraintsTest#testSchedulePeriodic |
| JS-TC-004 | TimeController.java | `maybeUpdateDelayAlarmLocked()` | ~250-300 | COND, STATE | Medium | TimingConstraintsTest#testCancel |
| JS-TC-005 | TimeController.java | `checkExpiredDeadlinesAndResetAlarm()` | ~300-350 | COND, CALC | Medium | TimingConstraintsTest#testSchedulePeriodic_lowFlex |
| JS-TC-006 | JobStatus.java | `getLatestRunTimeElapsed()` | ~800-820 | CALC | Easy | TimingConstraintsTest |
| JS-TC-007 | JobStatus.java | `getEarliestRunTime()` | ~820-840 | CALC | Easy | TimingConstraintsTest |

### 2. Connectivity Constraints (網路約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-CC-001 | ConnectivityController.java | `isSatisfied()` | ~400-450 | COND | Easy | ConnectivityConstraintTest#testConnectivityConstraintExecutes_metered |
| JS-CC-002 | ConnectivityController.java | `updateConstraintsSatisfied()` | ~500-600 | COND, STATE | Medium | ConnectivityConstraintTest#testConnectivityConstraintExecutes_unmetered |
| JS-CC-003 | ConnectivityController.java | `isNetworkBlocked()` | ~650-700 | COND, BOUND | Medium | ConnectivityConstraintTest#testConnectivityConstraintFails_noNetwork |
| JS-CC-004 | ConnectivityController.java | `getBlockedReasons()` | ~700-750 | COND | Medium | ConnectivityConstraintTest |
| JS-CC-005 | ConnectivityController.java | `maybeRegisterNetworkCallbackLocked()` | ~800-850 | STATE, ERR | Hard | ConnectivityConstraintTest |
| JS-CC-006 | ConnectivityController.java | `onNetworkActive()` | ~900-950 | COND, STATE | Medium | ConnectivityConstraintTest |
| JS-CC-007 | ConnectivityController.java | `sNetworkTransportAffinities` | ~130-140 | COND | Easy | ConnectivityConstraintTest#testCellularConstraint |
| JS-CC-008 | ConnectivityController.java | `UNBYPASSABLE_BG_BLOCKED_REASONS` | ~100-110 | COND | Medium | ConnectivityConstraintTest |

### 3. Battery Constraints (電池約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-BC-001 | BatteryController.java | `maybeStartTrackingJobLocked()` | ~68-85 | COND | Easy | BatteryConstraintTest#testChargingConstraintExecutes |
| JS-BC-002 | BatteryController.java | `setChargingConstraintSatisfied()` | ~78-82 | COND | Easy | BatteryConstraintTest#testChargingConstraintFails |
| JS-BC-003 | BatteryController.java | `setBatteryNotLowConstraintSatisfied()` | ~83-85 | COND | Easy | BatteryConstraintTest#testBatteryNotLowConstraint |
| JS-BC-004 | BatteryController.java | `hasTopExemptionLocked()` | ~75-78 | COND | Medium | BatteryConstraintTest |
| JS-BC-005 | BatteryController.java | `onBatteryStateChangedLocked()` | ~130-140 | STATE | Medium | BatteryConstraintTest |
| JS-BC-006 | BatteryController.java | `maybeReportNewChargingStateLocked()` | ~145-180 | COND, STATE | Medium | BatteryConstraintTest |
| JS-BC-007 | JobSchedulerService.java | `BatteryStateTracker.onReceiveInternal()` | ~4418-4500 | COND, STATE | Hard | BatteryConstraintTest |

### 4. Idle Constraints (閒置約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-IC-001 | IdleController.java | `maybeStartTrackingJobLocked()` | ~60-70 | COND | Easy | IdleConstraintTest#testIdleConstraintExecutes |
| JS-IC-002 | IdleController.java | `setIdleConstraintSatisfied()` | ~65-68 | COND | Easy | IdleConstraintTest#testIdleConstraintFails |
| JS-IC-003 | IdleController.java | `reportNewIdleState()` | ~105-120 | COND, STATE | Medium | IdleConstraintTest |
| JS-IC-004 | idle/DeviceIdlenessTracker.java | `isIdle()` | - | COND | Medium | IdleConstraintTest#testScreenOnStopsIdle |
| JS-IC-005 | idle/CarIdlenessTracker.java | `isIdle()` | - | COND | Medium | IdleConstraintTest (Automotive) |
| JS-IC-006 | IdleController.java | `initIdleStateTracker()` | ~120-130 | COND | Easy | IdleConstraintTest |

### 5. Storage Constraints (儲存約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-SC-001 | StorageController.java | `maybeStartTrackingJobLocked()` | ~60-70 | COND | Easy | StorageConstraintTest#testNotLowConstraintExecutes |
| JS-SC-002 | StorageController.java | `setStorageNotLowConstraintSatisfied()` | ~68-70 | COND | Easy | StorageConstraintTest#testNotLowConstraintFails |
| JS-SC-003 | StorageController.java | `StorageTracker.isStorageNotLow()` | ~110-112 | COND | Easy | StorageConstraintTest |
| JS-SC-004 | StorageController.java | `StorageTracker.onReceiveInternal()` | ~120-145 | COND, STATE | Medium | StorageConstraintTest |
| JS-SC-005 | StorageController.java | `maybeReportNewStorageState()` | ~75-95 | STATE | Medium | StorageConstraintTest |

### 6. Quota & Throttling (配額與節流)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-QC-001 | QuotaController.java | `isWithinQuotaLocked()` | ~1500-1600 | COND, CALC | Hard | JobThrottlingTest#testRestrictedBucketJobsDeferred |
| JS-QC-002 | QuotaController.java | `getRemainingExecutionTimeLocked()` | ~1600-1700 | CALC | Medium | JobThrottlingTest |
| JS-QC-003 | QuotaController.java | `ExecutionStats` class | ~108-150 | CALC, STATE | Medium | JobThrottlingTest |
| JS-QC-004 | QuotaController.java | `maybeUpdateBudgetLocked()` | ~2000-2100 | CALC, STATE | Hard | JobThrottlingTest#testBatterySaverThrottling |
| JS-QC-005 | QuotaController.java | `getStandbyBucket()` | ~2200-2250 | COND | Medium | JobThrottlingTest#testBucketTransition |
| JS-QC-006 | QuotaController.java | `updateExecutionStatsLocked()` | ~1700-1800 | CALC | Hard | JobThrottlingTest |
| JS-QC-007 | DeviceIdleJobsController.java | `updateAllowedJobsLocked()` | ~200-250 | COND, STATE | Medium | JobThrottlingTest#testDozeThrottling |
| JS-QC-008 | DeviceIdleJobsController.java | `isExempted()` | ~250-280 | COND | Medium | JobThrottlingTest |
| JS-QC-009 | BackgroundJobsController.java | `isBackgroundRestricted()` | ~200-250 | COND | Medium | JobThrottlingTest |

### 7. Expedited Jobs (加急任務)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-EJ-001 | JobSchedulerService.java | `isExpeditedJobReady()` | ~3600-3650 | COND | Medium | ExpeditedJobTest#testJobUidState_noRequiredNetwork |
| JS-EJ-002 | JobStatus.java | `isRequestedExpeditedJob()` | ~1200-1220 | COND | Easy | ExpeditedJobTest |
| JS-EJ-003 | JobStatus.java | `shouldTreatAsExpeditedJob()` | ~1220-1250 | COND | Medium | ExpeditedJobTest |
| JS-EJ-004 | QuotaController.java | `getEJLimitMs()` | ~2500-2550 | CALC | Medium | ExpeditedJobTest |
| JS-EJ-005 | JobConcurrencyManager.java | expedited job handling | - | COND, STATE | Hard | ExpeditedJobTest#testJobUidState_withRequiredNetwork |

### 8. User-Initiated Jobs (用戶發起任務)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-UI-001 | JobSchedulerService.java | `isUserInitiatedJobReady()` | ~3650-3700 | COND | Medium | UserInitiatedJobTest |
| JS-UI-002 | JobStatus.java | `isUserInitiatedJob()` | ~1250-1270 | COND | Easy | UserInitiatedJobTest |
| JS-UI-003 | JobNotificationCoordinator.java | notification handling | - | STATE, ERR | Hard | UserInitiatedJobTest#testNotificationRequired |
| JS-UI-004 | JobServiceContext.java | `executeRunnableJob()` | - | COND, STATE | Hard | UserInitiatedJobTest |

### 9. Flexibility Constraints (彈性約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-FC-001 | FlexibilityController.java | `isFlexibilitySatisfiedLocked()` | ~400-450 | COND | Medium | FlexibilityConstraintTest |
| JS-FC-002 | FlexibilityController.java | `mAppliedConstraints` | ~130-135 | STATE | Medium | FlexibilityConstraintTest |
| JS-FC-003 | FlexibilityController.java | `mPercentsToDropConstraints` | ~145-150 | CALC | Hard | FlexibilityConstraintTest |
| JS-FC-004 | FlexibilityController.java | `FLEXIBLE_CONSTRAINTS` | ~80-85 | COND | Easy | FlexibilityConstraintTest |
| JS-FC-005 | FlexibilityController.java | `calculateNumDroppedConstraints()` | ~500-550 | CALC | Hard | FlexibilityConstraintTest |
| JS-FC-006 | FlexibilityController.java | `mFallbackFlexibilityDeadlineMs` | ~90-95 | CALC | Medium | FlexibilityConstraintTest |

### 10. Content Trigger (內容觸發)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-CT-001 | ContentObserverController.java | `maybeStartTrackingJobLocked()` | ~200-250 | COND, STATE | Medium | TriggerContentTest#testMediaUri |
| JS-CT-002 | ContentObserverController.java | `onContentChange()` | ~300-350 | COND, STATE | Medium | TriggerContentTest |
| JS-CT-003 | ContentObserverController.java | `hasTriggerContentConstraint()` | ~250-280 | COND | Easy | TriggerContentTest |
| JS-CT-004 | JobStatus.java | `setContentTriggerConstraintSatisfied()` | ~1400-1420 | COND | Easy | TriggerContentTest |

### 11. Job Scheduling Core (排程核心)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-JS-001 | JobSchedulerService.java | `schedule()` | ~2100-2200 | COND, ERR | Medium | JobSchedulingTest |
| JS-JS-002 | JobSchedulerService.java | `cancelJobImplLocked()` | ~2371-2450 | COND, STATE | Medium | TimingConstraintsTest#testCancel |
| JS-JS-003 | JobSchedulerService.java | `isReadyToBeExecutedLocked()` | ~3700-3800 | COND | Hard | JobSchedulingTest |
| JS-JS-004 | JobSchedulerService.java | `maybeQueueReadyJobsForExecutionLocked()` | ~3970-4000 | COND, STATE | Hard | JobSchedulingTest |
| JS-JS-005 | JobStore.java | `add()` / `remove()` | - | STATE, SYNC | Hard | JobSchedulingTest |
| JS-JS-006 | PendingJobQueue.java | queue operations | - | STATE, SYNC | Medium | JobSchedulingTest |

### 12. Job Work Items (工作項目)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-WI-001 | JobWorkItem.java (framework) | `getDeliveryCount()` | - | CALC | Easy | JobWorkItemTest#testAllInfoGivenToJob |
| JS-WI-002 | JobWorkItem.java (framework) | `getEstimatedNetworkBytes()` | - | CALC | Easy | JobWorkItemTest |
| JS-WI-003 | JobServiceContext.java | `dequeueWork()` | - | STATE | Medium | JobWorkItemTest |
| JS-WI-004 | JobServiceContext.java | `completeWork()` | - | STATE | Medium | JobWorkItemTest |

### 13. JobInfo Configuration (任務配置)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-JI-001 | JobInfo.java (framework) | `getMinPeriodMillis()` | - | CALC, BOUND | Easy | JobInfoTest#testPeriodic |
| JS-JI-002 | JobInfo.java (framework) | `getMinFlexMillis()` | - | CALC, BOUND | Easy | JobInfoTest#testPeriodic |
| JS-JI-003 | JobInfo.java (framework) | `Builder.setBackoffCriteria()` | - | COND, BOUND | Easy | JobInfoTest#testBackoffCriteria |
| JS-JI-004 | JobInfo.java (framework) | `Builder.setRequiredNetworkType()` | - | COND | Easy | JobInfoTest |
| JS-JI-005 | JobInfo.java (framework) | `Builder.setEstimatedNetworkBytes()` | - | CALC, BOUND | Medium | JobInfoTest |
| JS-JI-006 | JobInfo.java (framework) | `Builder.setPersisted()` | - | COND | Easy | JobInfoTest |

### 14. Data Transfer (資料傳輸)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-DT-001 | JobParameters.java (framework) | `updateEstimatedNetworkBytes()` | - | CALC | Easy | DataTransferTest#testUpdateEstimatedNetworkBytes |
| JS-DT-002 | JobParameters.java (framework) | `updateTransferredNetworkBytes()` | - | CALC | Easy | DataTransferTest#testUpdateTransferredNetworkBytes |
| JS-DT-003 | JobServiceContext.java | network byte tracking | - | CALC, STATE | Medium | DataTransferTest |

### 15. Notification (通知)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-NT-001 | JobNotificationCoordinator.java | `setNotification()` | - | STATE | Medium | NotificationTest#testNotificationJobEndDetach |
| JS-NT-002 | JobNotificationCoordinator.java | notification lifecycle | - | STATE, ERR | Hard | NotificationTest |
| JS-NT-003 | JobService.java (framework) | `JOB_END_NOTIFICATION_POLICY_*` | - | COND | Easy | NotificationTest |

### 16. Component Constraints (元件約束)

| ID | AOSP 檔案 | 函數/區塊 | 行號範圍 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|----------|----------|------|---------------|
| JS-CP-001 | ComponentController.java | `maybeStartTrackingJobLocked()` | ~100-150 | COND, STATE | Medium | ComponentConstraintTest |
| JS-CP-002 | ComponentController.java | `isComponentUsable()` | ~150-200 | COND | Medium | ComponentConstraintTest |

---

## 注入點統計

### 按類別分布

| 類別 | 數量 | 難度分布 |
|------|------|----------|
| Timing Constraints | 7 | E:4, M:3, H:0 |
| Connectivity Constraints | 8 | E:2, M:5, H:1 |
| Battery Constraints | 7 | E:3, M:3, H:1 |
| Idle Constraints | 6 | E:3, M:3, H:0 |
| Storage Constraints | 5 | E:3, M:2, H:0 |
| Quota & Throttling | 9 | E:0, M:6, H:3 |
| Expedited Jobs | 5 | E:1, M:3, H:1 |
| User-Initiated Jobs | 4 | E:1, M:1, H:2 |
| Flexibility Constraints | 6 | E:1, M:3, H:2 |
| Content Trigger | 4 | E:2, M:2, H:0 |
| Job Scheduling Core | 6 | E:0, M:3, H:3 |
| Job Work Items | 4 | E:2, M:2, H:0 |
| JobInfo Configuration | 6 | E:5, M:1, H:0 |
| Data Transfer | 3 | E:2, M:1, H:0 |
| Notification | 3 | E:1, M:1, H:1 |
| Component Constraints | 2 | E:0, M:2, H:0 |
| **總計** | **78** | **E:28, M:32, H:18** |

### 按注入類型分布

| 類型 | 說明 | 出現次數 |
|------|------|----------|
| COND | 條件判斷 | 58 |
| STATE | 狀態轉換 | 32 |
| CALC | 數值計算 | 22 |
| BOUND | 邊界檢查 | 5 |
| ERR | 錯誤處理 | 5 |
| SYNC | 同步問題 | 2 |

---

## 重點注入區域

### 高價值注入點（建議優先出題）

1. **TimeController.evaluateDeadlineConstraint()** - 死線計算邏輯，易於理解且影響明顯
2. **ConnectivityController.isSatisfied()** - 網路約束核心判斷
3. **BatteryController.setChargingConstraintSatisfied()** - 充電狀態判斷
4. **QuotaController.isWithinQuotaLocked()** - 配額計算核心
5. **FlexibilityController.isFlexibilitySatisfiedLocked()** - 彈性約束判斷

### 跨模組注入點（適合 Hard 難度）

1. **JobSchedulerService + Controllers** - 多控制器協調
2. **QuotaController + DeviceIdleJobsController** - 節流策略組合
3. **ConnectivityController + BackgroundJobsController** - 網路+背景限制

---

## 建議出題策略

### Easy (28 題)
- 單一約束條件判斷
- 明顯的數值計算錯誤
- 直接的狀態檢查

### Medium (32 題)
- 跨函數的邏輯追蹤
- 狀態轉換時機問題
- 多條件組合判斷

### Hard (18 題)
- 跨控制器的邏輯
- 複雜的配額計算
- 並發與同步問題

---

**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/JobScheduler.md`  
**版本**: v1.0.0
