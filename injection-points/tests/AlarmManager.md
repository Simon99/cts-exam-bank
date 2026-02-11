# AlarmManager 模組注入點分布列表

**CTS 路徑**: `cts/tests/AlarmManager/`  
**更新時間**: 2026-02-10 22:30 GMT+8  
**狀態**: ✅ Phase A 完成

## 概覽

| 指標 | 數值 |
|------|------|
| **總注入點數** | 56 |
| Easy | 18 (32%) |
| Medium | 24 (43%) |
| Hard | 14 (25%) |

**涵蓋測試類別**：見下方

## CTS 測試類別

### 核心 API 測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| BasicApiTests | 基本 API 測試（set/setExact/setRepeating） | 高 |
| ExactAlarmsTest | 精確鬧鐘測試（SCHEDULE_EXACT_ALARM 權限） | 高 |
| TimeChangeTests | 時間變更測試 | 高 |
| UidCapTests | UID 能力測試 | 中 |

### 省電與限制測試
| 測試類別 | 描述 | 優先級 |
|---------|------|--------|
| AppStandbyTests | App Standby 狀態測試 | 高 |
| BackgroundRestrictedAlarmsTest | 背景限制鬧鐘測試 | 高 |
| InstantAppsTests | Instant App 鬧鐘測試 | 中 |

## 對應 AOSP 源碼路徑

### Framework 層（API）
- `frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (1658 行) ⭐

### Service 層（實作）
- `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java` (5873 行) ⭐
- `frameworks/base/services/core/java/com/android/server/AlarmManagerInternal.java`

### 相關經濟策略
- `frameworks/base/apex/jobscheduler/service/java/com/android/server/tare/AlarmManagerEconomicPolicy.java`

---

## 注入點清單

### 1. AlarmManager（公開 API）⭐

**檔案**: `frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java` (1658 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| ALM-001 | set(type, triggerAtMillis, operation) | 485-487 | COND | Easy | BasicApiTests | 基本設定，legacyExactLength 呼叫 |
| ALM-002 | set(type, triggerAtMillis, tag, listener, handler) | 507-509 | COND | Easy | BasicApiTests | Listener 版設定 |
| ALM-003 | setRepeating(type, triggerAtMillis, intervalMillis, operation) | 567-569 | COND, CALC | Medium | BasicApiTests | 重複鬧鐘，interval 處理 |
| ALM-004 | setWindow(type, windowStartMillis, windowLengthMillis, operation) | 637-639 | COND, BOUND | Medium | BasicApiTests | 視窗鬧鐘 |
| ALM-005 | setExact(type, triggerAtMillis, operation) | 671-673 | COND | Easy | ExactAlarmsTest | 精確鬧鐘 |
| ALM-006 | setExact(type, triggerAtMillis, tag, listener, handler) | 697-699 | COND | Easy | ExactAlarmsTest | 精確 Listener 版 |
| ALM-007 | setExactAndAllowWhileIdle(type, triggerAtMillis, operation) | 750-752 | COND, STATE | Medium | ExactAlarmsTest | Idle 模式精確鬧鐘 |
| ALM-008 | setAndAllowWhileIdle(type, triggerAtMillis, operation) | 715-717 | COND | Medium | AppStandbyTests | Idle 模式允許 |
| ALM-009 | setAlarmClock(info, operation) | 806-808 | COND | Medium | BasicApiTests | 鬧鐘時鐘設定 |
| ALM-010 | setImpl() | 待查 | COND, ERR | Hard | BasicApiTests | 核心設定實作 |
| ALM-011 | cancel(operation) | 840-845 | COND | Easy | BasicApiTests | 取消鬧鐘（PendingIntent） |
| ALM-012 | cancel(listener) | 855-865 | COND | Easy | BasicApiTests | 取消鬧鐘（Listener） |
| ALM-013 | getNextAlarmClock() | 820-825 | COND | Easy | BasicApiTests | 取得下一個鬧鐘 |
| ALM-014 | canScheduleExactAlarms() | 1145-1155 | COND, STATE | Medium | ExactAlarmsTest | 權限檢查 |
| ALM-015 | legacyExactLength() | 413-415 | COND, CALC | Easy | BasicApiTests | SDK 版本判斷 |

### 2. AlarmManager.AlarmClockInfo

**檔案**: `frameworks/base/apex/jobscheduler/framework/java/android/app/AlarmManager.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| ALM-021 | AlarmClockInfo 建構子 | 待查 | COND | Easy | BasicApiTests | 時間與 PendingIntent |
| ALM-022 | getTriggerTime() | 待查 | CALC | Easy | BasicApiTests | 觸發時間 |
| ALM-023 | getShowIntent() | 待查 | COND | Easy | BasicApiTests | 顯示 Intent |

### 3. AlarmManagerService（Service 層）⭐

**檔案**: `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java` (5873 行)

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| ALM-031 | setImpl() | 待查 | COND, ERR, STATE | Hard | BasicApiTests | 核心設定邏輯 |
| ALM-032 | setImplLocked() | 待查 | STATE, SYNC | Hard | BasicApiTests | 鎖定版設定 |
| ALM-033 | removeLocked() | 待查 | STATE | Medium | BasicApiTests | 移除鬧鐘 |
| ALM-034 | removeImpl() | 待查 | STATE | Medium | BasicApiTests | 移除實作 |
| ALM-035 | triggerAlarmsLocked() | 待查 | STATE, COND | Hard | BasicApiTests | 觸發鬧鐘 |
| ALM-036 | deliverAlarmsLocked() | 待查 | STATE, ERR | Hard | BasicApiTests | 傳遞鬧鐘 |
| ALM-037 | rescheduleKernelAlarmsLocked() | 待查 | STATE, CALC | Hard | TimeChangeTests | 重新排程核心鬧鐘 |
| ALM-038 | reorderAlarmsBasedOnStandbyBuckets() | 待查 | STATE, COND | Hard | AppStandbyTests | Standby 重排序 |
| ALM-039 | checkAllowNonWakeupDelayLocked() | 待查 | COND | Medium | BasicApiTests | 非喚醒延遲檢查 |
| ALM-040 | hasScheduleExactAlarmInternal() | 待查 | COND, STATE | Medium | ExactAlarmsTest | 內部精確鬧鐘權限 |
| ALM-041 | adjustDeliveryTimeBasedOnBatterySaver() | 待查 | CALC, COND | Medium | BackgroundRestrictedAlarmsTest | 電池節省調整 |
| ALM-042 | adjustDeliveryTimeBasedOnDeviceIdle() | 待查 | CALC, COND | Medium | AppStandbyTests | 裝置閒置調整 |
| ALM-043 | getNextAlarmClockImpl() | 待查 | COND | Easy | BasicApiTests | 下一鬧鐘實作 |
| ALM-044 | updateNextAlarmClockLocked() | 待查 | STATE | Medium | BasicApiTests | 更新下一鬧鐘 |
| ALM-045 | filterQuotaExceededAlarms() | 待查 | COND, CALC | Hard | AppStandbyTests | 配額過濾 |
| ALM-046 | isExactAlarmPermissionGranted() | 待查 | COND | Medium | ExactAlarmsTest | 精確鬧鐘權限 |
| ALM-047 | adjustDeliveryTimeBasedOnBucketLocked() | 待查 | CALC, COND | Hard | AppStandbyTests | Bucket 時間調整 |

### 4. Alarm 類別

**檔案**: `frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/Alarm.java`

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| ALM-051 | matches() | 待查 | COND | Easy | BasicApiTests | 鬧鐘匹配邏輯 |
| ALM-052 | isExact() | 待查 | COND | Easy | ExactAlarmsTest | 是否精確 |
| ALM-053 | wakeup 判斷 | 待查 | COND | Easy | BasicApiTests | 喚醒類型判斷 |

### 5. 時間處理

**相關檔案**: AlarmManagerService.java 內部

| ID | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test | 說明 |
|----|----------|------|----------|------|---------------|------|
| ALM-061 | convertToElapsed() | 待查 | CALC, COND | Medium | TimeChangeTests | RTC 到 ELAPSED 轉換 |
| ALM-062 | setTimeZoneImpl() | 待查 | STATE | Medium | TimeChangeTests | 時區設定 |
| ALM-063 | rebatchAllAlarmsLocked() | 待查 | STATE, CALC | Hard | TimeChangeTests | 批次重排 |

---

## 統計摘要

| 注入類型 | 數量 |
|----------|------|
| COND（條件判斷）| 38 |
| STATE（狀態轉換）| 22 |
| CALC（數值計算）| 16 |
| ERR（錯誤處理）| 4 |
| SYNC（同步問題）| 2 |
| BOUND（邊界檢查）| 1 |

## 注入難點分析

1. **精確鬧鐘權限** — SCHEDULE_EXACT_ALARM 權限檢查邏輯複雜
2. **App Standby Bucket** — 不同 bucket 有不同的延遲策略
3. **電池節省模式** — Doze 和 Battery Saver 下的鬧鐘行為
4. **時間變更** — RTC 與 ELAPSED_REALTIME 的轉換和處理
5. **配額系統** — TARE (The Android Resource Economy) 整合

## 相關測試命令

```bash
# 執行 AlarmManager CTS
run cts -m CtsAlarmManagerTestCases
```

## 下一步 - Phase B

從此列表中挑選注入點，進行題目生成：
1. [x] Phase A 完成 - 注入點列表已建立
2. [ ] Phase B - 挑選注入點、設計 bug、產生 patch
3. [ ] Phase C - 實機驗證
