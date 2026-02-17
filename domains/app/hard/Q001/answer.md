# Q001: 答案解析

## 問題根源

在 `RootWindowContainer.java` 的 `findTask()` 方法中，當在優先 TaskDisplayArea 找到完美匹配（ideal match）後，沒有立即返回，而是繼續搜索其他 display areas，可能導致返回錯誤的 Activity。

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/wm/RootWindowContainer.java`

```java
ActivityRecord findTask(int activityType, String taskAffinity, Intent intent, ActivityInfo info,
        TaskDisplayArea preferredTaskDisplayArea) {
    ProtoLog.d(WM_DEBUG_TASKS, "Looking for task of type=%s, taskAffinity=%s...");
    mTmpFindTaskResult.init(activityType, taskAffinity, intent, info);

    ActivityRecord candidateActivity = null;
    if (preferredTaskDisplayArea != null) {
        mTmpFindTaskResult.process(preferredTaskDisplayArea);
        // BUG: 刪除了 ideal match 的 early return
        // 應該是：
        // if (mTmpFindTaskResult.mIdealRecord != null) {
        //     return mTmpFindTaskResult.mIdealRecord;
        // } else if (...) { ... }
        if (mTmpFindTaskResult.mCandidateRecord != null) {
            candidateActivity = mTmpFindTaskResult.mCandidateRecord;
        }
    }

    // 繼續搜索其他 display areas，可能覆蓋 preferred 上的結果
    final ActivityRecord idealMatchActivity = getItemFromTaskDisplayAreas(taskDisplayArea -> {
        // ...
    });
    // ...
}
```

## 診斷步驟

1. **添加 log 追蹤 Task 查找**:
```java
// RootWindowContainer.java findTask()
Log.d("RootWindowContainer", "findTask: preferredTDA=" + preferredTaskDisplayArea);
Log.d("RootWindowContainer", "After preferred TDA: idealRecord=" + mTmpFindTaskResult.mIdealRecord
    + " candidateRecord=" + mTmpFindTaskResult.mCandidateRecord);
```

2. **觀察 log**:
```
D RootWindowContainer: findTask: preferredTDA=DefaultTaskDisplayArea
D RootWindowContainer: After preferred TDA: idealRecord=ActivityA candidateRecord=ActivityA
D RootWindowContainer: Searching other displays...
D RootWindowContainer: Final result: ActivityB  // 錯誤！應該是 ActivityA
```

3. **問題定位**: 
   - 在 preferredTaskDisplayArea 找到了 ideal match (ActivityA)
   - 但沒有 early return，繼續搜索其他 display areas
   - 在其他地方找到了另一個 ideal match (ActivityB)，覆蓋了結果

## 問題分析

`findTask()` 的設計意圖：
1. 優先在 preferredTaskDisplayArea 上尋找 Task
2. 如果找到 ideal match，應立即返回（尊重 preference）
3. 只有在 preferred 上沒有 ideal match 時，才搜索其他 displays

Bug 刪除了 ideal match 的 early return，導致：
- 即使在 preferred display 找到了完美匹配，仍繼續搜索
- 可能返回其他 display 上的 Task，違反了 TaskDisplayArea preference

## 正確代碼

```java
ActivityRecord candidateActivity = null;
if (preferredTaskDisplayArea != null) {
    mTmpFindTaskResult.process(preferredTaskDisplayArea);
    // 正確: 找到 ideal match 立即返回
    if (mTmpFindTaskResult.mIdealRecord != null) {
        return mTmpFindTaskResult.mIdealRecord;
    } else if (mTmpFindTaskResult.mCandidateRecord != null) {
        candidateActivity = mTmpFindTaskResult.mCandidateRecord;
    }
}
```

## 修復驗證

```bash
atest android.app.cts.ActivityManagerTest#testSingleTaskLaunchMode
atest com.android.server.wm.RootWindowContainerTests#testFindTaskPreferredDisplayArea
```

## 難度分類理由

**Hard** - 需要理解多 Display 環境下的 Task 查找邏輯、TaskDisplayArea 的優先級機制，以及 mTmpFindTaskResult 的 ideal vs candidate 語義。涉及 Activity 啟動流程中的 Task 重用決策。
