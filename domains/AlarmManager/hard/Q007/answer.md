# Q007 Answer: filterQuotaExceededAlarms Wrong Quota Tracking

## 正確答案
**C. 配額計數器在每次鬧鐘觸發後沒有正確遞增**

## 問題根因
在 `AlarmManagerService.java` 的配額管理邏輯中，
每個 app 的鬧鐘計數應該在鬧鐘實際觸發時遞增。
但 bug 在遞增計數器時使用了錯誤的方法：`put()` 而非 `increment()`，
或者根本漏掉了遞增操作。這導致計數器永遠是 0，配額檢查永遠通過。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void recordAlarmFired(int uid) {
    // BUG: 漏掉了遞增，或使用了錯誤的方法
    mAlarmCounts.get(uid);  // 只讀取但沒有遞增
}

// 或者另一種 bug
void recordAlarmFired(int uid) {
    int current = mAlarmCounts.get(uid, 0);
    // BUG: put 了相同的值，沒有 +1
    mAlarmCounts.put(uid, current);
}

// 正確的代碼
void recordAlarmFired(int uid) {
    int current = mAlarmCounts.get(uid, 0);
    mAlarmCounts.put(uid, current + 1);
}
```

## 相關知識
- TARE (The Android Resource Economy) 管理 app 資源配額
- 不同 standby bucket 有不同的鬧鐘配額
- 配額用於防止 app 濫用鬧鐘消耗電力

## 難度說明
**Hard** - 需要理解配額系統的完整流程，包括計數、檢查和重置。
