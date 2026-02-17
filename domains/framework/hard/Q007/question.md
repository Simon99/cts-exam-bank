# Q007: Activity 進入 RESUMED 狀態後進程優先級未正確更新

## CTS 測試失敗現象

```
android.server.wm.lifecycle.ActivityLifecycleTests#testResumedActivityProcessPriority FAILED

java.lang.AssertionError: Expected process state PROCESS_STATE_TOP but was PROCESS_STATE_FOREGROUND_SERVICE
    at android.server.wm.lifecycle.ActivityLifecycleTests.testResumedActivityProcessPriority(ActivityLifecycleTests.java:1847)
```

## 測試代碼片段

```java
@Test
public void testResumedActivityProcessPriority() throws Exception {
    final Activity activity = launchTestActivity();
    waitAndAssertActivityState(activity, ON_RESUME);
    
    // 驗證進程狀態是否正確更新為 TOP
    final ActivityManager am = getContext().getSystemService(ActivityManager.class);
    final List<RunningAppProcessInfo> processes = am.getRunningAppProcesses();
    
    RunningAppProcessInfo targetProcess = null;
    for (RunningAppProcessInfo process : processes) {
        if (process.processName.equals(getContext().getPackageName())) {
            targetProcess = process;
            break;
        }
    }
    
    assertNotNull("Process not found", targetProcess);
    // 期望 RESUMED Activity 的進程應該是 IMPORTANCE_FOREGROUND
    assertEquals("Process importance should be FOREGROUND",
            RunningAppProcessInfo.IMPORTANCE_FOREGROUND,
            targetProcess.importance);
    
    // 驗證進程被正確標記為包含可見 Activity
    assertTrue("Process should have activities", 
            targetProcess.importanceReasonCode == 
                RunningAppProcessInfo.REASON_UNKNOWN);
}
```

## 背景信息

- Activity 狀態透過 `ActivityRecord.setState()` 管理
- 進程優先級（OOM Adj）會根據 Activity 狀態更新
- RESUMED 和 STARTED 狀態都需要將進程標記為前台
- 進程資訊更新會影響系統記憶體管理決策

## 相關源碼路徑

- `frameworks/base/services/core/java/com/android/server/wm/ActivityRecord.java`
- `frameworks/base/services/core/java/com/android/server/wm/ActivityTaskSupervisor.java`
- `frameworks/base/services/core/java/com/android/server/am/ProcessList.java`

## 你的任務

1. 分析 `ActivityRecord.setState()` 中狀態轉換的邏輯
2. 理解 RESUMED 和 STARTED 狀態處理的關聯
3. 找出為什麼進程優先級沒有正確更新
4. 提供修復方案

---

**這個問題的根本原因是什麼？**

A) `setState()` 方法在 RESUMED 狀態時過早返回，沒有調用 `onProcessActivityStateChanged()`

B) `setState()` 方法在 RESUMED 狀態時缺少 fall-through 到 STARTED 的邏輯，導致 `updateProcessInfo()` 未被調用

C) `updateBatteryStats()` 錯誤地將進程標記為後台

D) `updateActivityUsageStats()` 與 `updateProcessInfo()` 有競態條件
