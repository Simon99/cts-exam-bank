# DIS-M001: 解答

## Bug 位置

**檔案**: `frameworks/base/services/core/java/com/android/server/display/BrightnessTracker.java`

**問題代碼** (約第 437-441 行):
```java
mEventsDirty = true;
synchronized (mEventsLock) {
    mEvents.append(event);
}
```

## 問題分析

### 根本原因

`mEventsDirty` 標記被設置在 `synchronized (mEventsLock)` 區塊**外面**，但它與 `mEvents` 是相關聯的狀態。這造成了 **競態條件 (Race Condition)**。

### 詳細說明

1. **`mEventsDirty` 的用途**:
   - 這個標記指示事件列表是否有新增內容需要持久化到磁碟
   - 在 `persistBrightnessTrackerState()` 方法中被讀取
   - 該方法由 `BrightnessIdleJob` 在系統空閒時調用

2. **競態條件場景**:
   ```
   Thread A (亮度變更)           Thread B (持久化)
   ─────────────────           ─────────────────
   mEventsDirty = true;
                                if (mEventsDirty) {  // 讀到 true
   synchronized (mEventsLock) {
       mEvents.append(event);
                                    synchronized (mEventsLock) {
                                        // 等待...
   }
                                        // 獲得鎖，寫入舊數據
                                        writeEvents(events);
                                    }
                                    mEventsDirty = false;
                                }
   ```

3. **結果**:
   - Thread A 設置 dirty 標記後，在 append event 之前
   - Thread B 看到 dirty=true，獲取當時的 events (不包含新 event)
   - Thread B 寫入不完整的數據，並清除 dirty 標記
   - 新 event 永遠不會被持久化

### 為什麼多核設備更容易重現

- 多核設備上，Thread A 和 Thread B 真正並行執行
- 單核設備上，context switch 時機較少，競態窗口更難命中
- 快速滑動亮度條時，事件產生頻率高，增加競態機率

## 正確修復

```java
synchronized (mEventsLock) {
    mEventsDirty = true;
    mEvents.append(event);
}
```

**關鍵**: `mEventsDirty` 和 `mEvents.append()` 必須在同一個 synchronized 區塊內原子性地執行。

## 驗證方式

修復後重新執行:
```bash
atest CtsDisplayTestCases:BrightnessTest#testBrightnessSliderTracking
```

## 學習要點

1. **共享狀態的原子性**: 相關聯的多個變數修改應該原子性完成
2. **標記變數的危險**: `dirty` flag 特別容易出現競態條件
3. **多核 vs 單核測試**: 競態條件在多核設備上更容易暴露
4. **跨函數分析**: 理解 bug 需要追蹤 `mEventsDirty` 在 `persistBrightnessTrackerState()` 中的使用
