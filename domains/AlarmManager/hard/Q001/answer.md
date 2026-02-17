# Q001 Answer: setImpl Race Condition

## 正確答案
**A. `setImplLocked()` 在讀取 batch 大小和插入之間沒有持有鎖，導致 race condition**

## 問題根因
在 `AlarmManagerService.java` 的 `setImplLocked()` 方法中，
應該在整個批次操作期間持有鎖，但 bug 在讀取 batch 大小後釋放了鎖，
然後在實際插入時重新獲取鎖。在這個窗口期間，另一個執行緒可能已經修改了 batch，
導致計算出的索引不再有效，造成 ArrayIndexOutOfBoundsException。

## Bug 位置
`frameworks/base/apex/jobscheduler/service/java/com/android/server/alarm/AlarmManagerService.java`

## 修復方式
```java
// 錯誤的代碼
void setImplLocked(Alarm a) {
    int index;
    synchronized (mLock) {
        index = findInsertionIndexLocked(a);
    }
    // BUG: 在這裡釋放了鎖
    
    synchronized (mLock) {
        // 另一個執行緒可能已經修改了 batch，index 不再有效
        mAlarmBatches.get(batchIndex).add(index, a);
    }
}

// 正確的代碼
void setImplLocked(Alarm a) {
    synchronized (mLock) {
        int index = findInsertionIndexLocked(a);
        mAlarmBatches.get(batchIndex).add(index, a);
    }
}
```

## 相關知識
- TOCTOU (Time-of-check to time-of-use) 是常見的 race condition 類型
- 複合操作需要在單一同步區塊內完成
- AlarmManager 可能被多個 app 同時呼叫

## 難度說明
**Hard** - 需要理解 race condition 和 TOCTOU 問題，錯誤只偶發出現使得偵錯困難。
