# Q001: Activity LaunchMode singleTask 任務棧異常

## CTS 測試失敗現象

執行 `android.app.cts.ActivityManagerTest#testSingleTaskLaunchMode` 失敗

```
FAILURE: testSingleTaskLaunchMode
junit.framework.AssertionFailedError: 
    Expected activity to be brought to front of existing task
    Expected task id: 42, Actual task id: 58
    Expected activity count in task: 1, Actual: 2
    
    at android.app.cts.ActivityManagerTest.testSingleTaskLaunchMode(ActivityManagerTest.java:312)
```

## 測試代碼片段

```java
@Test
public void testSingleTaskLaunchMode() throws Exception {
    // 啟動 singleTask Activity A
    Intent intent = new Intent(mContext, SingleTaskActivity.class);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    mContext.startActivity(intent);
    
    int originalTaskId = getTopTaskId();
    Activity activityA = waitForActivity(SingleTaskActivity.class);
    
    // 從 A 啟動普通 Activity B
    activityA.startActivity(new Intent(activityA, NormalActivity.class));
    waitForActivity(NormalActivity.class);
    
    // 再次啟動 singleTask Activity A（應重用現有實例）
    Intent relaunchIntent = new Intent(mContext, SingleTaskActivity.class);
    relaunchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    mContext.startActivity(relaunchIntent);
    
    Thread.sleep(500);
    
    // 驗證：A 應該回到前台，B 應該被清除，task id 不變
    int currentTaskId = getTopTaskId();
    assertEquals("Task id should remain same", originalTaskId, currentTaskId);
    assertEquals("Should have only 1 activity", 1, getTaskActivityCount(currentTaskId));
}
```

## 症狀描述

- singleTask Activity 被重新啟動時創建了新 Task
- 原 Task 中的 Activity B 沒有被正確清除
- `FLAG_ACTIVITY_CLEAR_TOP` 效果沒有正確觸發

## 你的任務

1. 分析 singleTask launchMode 的實現機制
2. 找出為什麼新 Task 被創建而非重用
3. 理解 ActivityTaskSupervisor 和 Task 的交互
4. 提出修復方案

## 提示

- 相關源碼：
  - `frameworks/base/services/core/java/com/android/server/wm/ActivityStarter.java`
  - `frameworks/base/services/core/java/com/android/server/wm/Task.java`
  - `frameworks/base/services/core/java/com/android/server/wm/RootWindowContainer.java`
- 關注 `ActivityStarter.computeLaunchingTaskFlags()` 方法
- 關注 Task 的尋找邏輯 `findTask()`
