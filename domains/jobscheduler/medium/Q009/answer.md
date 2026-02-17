# Q009: 答案解析

## 問題根因
週期性作業的彈性窗口檢查邏輯錯誤，導致在窗口外也允許執行。

## Bug 位置
1. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/TimeController.java`
2. `frameworks/base/apex/jobscheduler/service/java/com/android/server/job/controllers/JobStatus.java`

## 錯誤代碼
```java
// 在 JobStatus 或 TimeController 中
public boolean isInFlexWindow(long nowElapsed) {
    if (!isPeriodic()) {
        return true;
    }
    // BUG: 彈性窗口計算錯誤
    // 或者判斷條件使用了錯誤的比較
    final long latestStart = getLatestRunTimeElapsed();
    final long earliestStart = latestStart - flexMillis;
    return nowElapsed > earliestStart;  // 應該是 >=
}
```

## 正確代碼
```java
public boolean isInFlexWindow(long nowElapsed) {
    if (!isPeriodic()) {
        return true;
    }
    final long latestStart = getLatestRunTimeElapsed();
    final long earliestStart = latestStart - flexMillis;
    // 只有在彈性窗口內才返回 true
    return nowElapsed >= earliestStart && nowElapsed <= latestStart;
}
```

## 調試步驟
1. 添加 log 輸出彈性窗口計算：
```java
Slog.d(TAG, "isInFlexWindow: now=" + nowElapsed 
        + " earliest=" + earliestStart + " latest=" + latestStart);
```

2. 檢查作業的 earliestRunTime 和 latestRunTime 是否正確設置

## 測試驗證
```bash
atest android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic_lowFlex
atest android.jobscheduler.cts.TimingConstraintsTest#testSchedulePeriodic
```

## 相關知識點
- 週期性作業有執行窗口（flex window）
- 作業只能在 `[latestRunTime - flex, latestRunTime]` 內執行
- `getMinFlexMillis()` 返回最小彈性窗口（5 分鐘）
