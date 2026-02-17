# Q007: Activity 進入 RESUMED 狀態後進程優先級未正確更新 - 解答

## 正確答案

**B) `setState()` 方法在 RESUMED 狀態時缺少 fall-through 到 STARTED 的邏輯，導致 `updateProcessInfo()` 未被調用**

## Bug 分析

### 問題根源

在 `ActivityRecord.setState()` 方法中，RESUMED 和 STARTED 兩個狀態原本設計為共享進程更新邏輯：

```java
switch (state) {
    case RESUMED:
        mAtmService.updateBatteryStats(this, true);
        mAtmService.updateActivityUsageStats(this, Event.ACTIVITY_RESUMED);
        // Fall through.  ← 這裡原本要 fall-through
    case STARTED:
        // Update process info while making an activity from invisible to visible
        if (app != null) {
            app.updateProcessInfo(false /* updateServiceConnectionActivities */,
                    true /* activityChange */, true /* updateOomAdj */,
                    true /* addPendingTopUid */);
        }
        // ... ContentCaptureManagerInternal 通知
        break;
```

### Bug 的影響

當 RESUMED case 後面加上了 `break;` 而非 fall-through 時：

1. **進程資訊未更新** — `updateProcessInfo()` 只在 STARTED 狀態執行
2. **OOM Adj 過高** — 進程可能被系統認為優先級較低
3. **前台進程識別失敗** — `addPendingTopUid` 未調用
4. **可能被錯誤回收** — 在記憶體緊張時，前台 Activity 的進程可能被殺

### 設計原因

RESUMED 和 STARTED 狀態都代表「Activity 對用戶可見」：
- **STARTED**: Activity 可見但未獲得焦點
- **RESUMED**: Activity 可見且獲得焦點

兩者都需要：
- 更新進程狀態為前台
- 調整 OOM Adj 到最高優先級
- 通知 ContentCaptureManager

## 選項分析

### A) 過早返回未調用 onProcessActivityStateChanged
❌ **錯誤**

`onProcessActivityStateChanged()` 在 switch 之前就已經調用：
```java
if (app != null) {
    mTaskSupervisor.onProcessActivityStateChanged(app, false /* forceBatch */);
}
```
這與 bug 無關。

### B) Fall-through 缺失
✅ **正確**

這正是問題所在。Java 的 switch-case 需要顯式 fall-through 或 break。

### C) updateBatteryStats 錯誤標記
❌ **錯誤**

`updateBatteryStats(this, true)` 中的 `true` 表示 resumed，與進程優先級無關。

### D) 競態條件
❌ **錯誤**

這兩個方法是同步調用的，沒有競態問題。

## 修復方案

移除 RESUMED case 末尾的 `break;`，恢復 fall-through：

```diff
 switch (state) {
     case RESUMED:
         mAtmService.updateBatteryStats(this, true);
         mAtmService.updateActivityUsageStats(this, Event.ACTIVITY_RESUMED);
-        break;
+        // Fall through.
     case STARTED:
```

## 延伸知識

### Android 進程優先級

| 狀態 | OOM Adj | 說明 |
|------|---------|------|
| 前台 Activity | 0 | 最高優先級，幾乎不會被殺 |
| 可見 Activity | 100 | 高優先級 |
| 服務 | 500 | 中等優先級 |
| 後台 | 900+ | 可能被殺 |

### Fall-through 最佳實踐

在 Java 中，如果 fall-through 是故意的，應加上註釋：
```java
case A:
    doSomething();
    // Fall through.
case B:
    doCommonThing();
    break;
```

現代 Java (12+) 可使用 switch expressions 避免此類問題：
```java
case RESUMED, STARTED -> {
    if (state == RESUMED) {
        mAtmService.updateBatteryStats(this, true);
        mAtmService.updateActivityUsageStats(this, Event.ACTIVITY_RESUMED);
    }
    if (app != null) {
        app.updateProcessInfo(...);
    }
}
```
