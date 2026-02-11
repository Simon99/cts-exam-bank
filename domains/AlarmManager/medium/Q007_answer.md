# Q007 Answer: Remove Alarm Doesn't Clear All Matching

## 正確答案
**A. `removeLocked()` 使用 `break` 而非 `continue` 導致提早退出迴圈**

## 問題根因
在 `AlarmManagerService.java` 的 `removeLocked()` 方法中，
當找到匹配的鬧鐘並移除後，應該繼續檢查是否有更多匹配的鬧鐘（使用 `continue`），
但 bug 使用了 `break`，導致找到第一個匹配後就退出迴圈，
無法移除其他使用相同 PendingIntent 的鬧鐘。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void removeLocked(PendingIntent operation, IAlarmListener listener) {
    for (int i = mAlarmBatches.size() - 1; i >= 0; i--) {
        Batch b = mAlarmBatches.get(i);
        if (b.remove(operation, listener)) {
            // Found a match
            if (b.size() == 0) {
                mAlarmBatches.remove(i);
            }
            break;  // BUG: 應該用 continue 繼續找其他匹配
        }
    }
}

// 正確的代碼
void removeLocked(PendingIntent operation, IAlarmListener listener) {
    for (int i = mAlarmBatches.size() - 1; i >= 0; i--) {
        Batch b = mAlarmBatches.get(i);
        if (b.remove(operation, listener)) {
            if (b.size() == 0) {
                mAlarmBatches.remove(i);
            }
            // continue to find more matches
        }
    }
}
```

## 相關知識
- 相同 PendingIntent 可以設定多個不同時間的鬧鐘
- cancel() 應該移除所有匹配的鬧鐘，而非只移除一個
- 鬧鐘按 batch 組織以支援 batching 優化

## 難度說明
**Medium** - 需要理解多鬧鐘匹配和移除的完整邏輯。
