# Q008 Answer

## 正確答案：B

## 解析

### 問題根因

`split()` 方法中的迴圈使用了錯誤的終止條件：

```java
// BUG 代碼
for (int h = 0; h < historySize; h++) {  // 應該是 h <= historySize
    final int historyPos = h == historySize ? HISTORY_CURRENT : h;
    // ...複製資料
}
```

當條件是 `h < historySize` 時，迴圈只會執行 `h = 0` 到 `h = historySize - 1`，永遠不會進入 `h == historySize` 的情況。因此，`HISTORY_CURRENT`（當前事件）的資料永遠不會被複製到分割後的事件中。

### 正確代碼

```java
// 正確實作
for (int h = 0; h <= historySize; h++) {  // 注意是 <=
    final int historyPos = h == historySize ? HISTORY_CURRENT : h;
    
    for (int i = 0; i < newPointerCount; i++) {
        nativeGetPointerCoords(mNativePtr, map[i], historyPos, pc[i]);
    }
    
    final long eventTimeNanos = nativeGetEventTimeNanos(mNativePtr, historyPos);
    if (h == 0) {
        ev.initialize(..., eventTimeNanos, ...);
    } else {
        nativeAddBatch(ev.mNativePtr, eventTimeNanos, pc, 0);
    }
}
```

### 迴圈邏輯解析

| historySize | 正確條件 (h <= historySize) | Bug 條件 (h < historySize) |
|-------------|---------------------------|---------------------------|
| 5 | h = 0,1,2,3,4,5 (6次) | h = 0,1,2,3,4 (5次) |
| 0 | h = 0 (1次) | 不執行 |

- 當 `h < historySize` (歷史事件)：複製歷史記錄
- 當 `h == historySize`：使用 `HISTORY_CURRENT` 複製當前事件

Bug 導致最關鍵的**當前事件**被遺漏！

### 為什麼其他選項不對

**A) nativeAddBatch() 參數錯誤**
- `nativeAddBatch()` 只在 `h > 0` 時調用，用於添加歷史記錄
- 當前事件使用 `initialize()` 設定，不是 `nativeAddBatch()`
- 如果是參數錯誤，歷史記錄也會出問題，但測試顯示歷史記錄正確

**C) initialize() 使用錯誤的 historyPos**
- `initialize()` 在 `h == 0` 時調用
- 當 `h == 0` 且 `historySize == 0` 時，`historyPos` 確實會是 `HISTORY_CURRENT`
- 但當有歷史記錄時 (`historySize > 0`)，第一次迭代 `h=0` 會正確使用 `historyPos=0`
- 問題不在 initialize()，而在於迴圈根本沒有執行到 `h == historySize`

**D) eventTimeNanos 未初始化**
- `eventTimeNanos` 在迴圈內宣告並立即賦值
- Java 區域變數必須在使用前初始化，否則編譯錯誤
- 不會出現「預設值 0」的情況

### 關鍵洞察

這是經典的「差一錯誤」(off-by-one error)。MotionEvent 的歷史機制將當前事件視為 "historySize 位置" 的特殊處理，容易在迴圈條件中出錯。

正確理解：
- `historySize` = 5 表示有 5 個歷史事件 (pos 0-4) + 1 個當前事件
- 總共需要複製 **6** 個資料點
- 迴圈需要執行 historySize + 1 次
