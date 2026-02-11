# Q010 Answer

## 正確答案：A

## 解析

### 問題根因
`obtain()` 方法從物件池取出已回收的事件後，只更新了部分欄位（如 X 座標），未完整重新初始化所有必要欄位。導致 Y 座標保留了前一個事件的值。

### Bug 程式碼
```java
public static MotionEvent obtain(long downTime, long eventTime, int action,
        float x, float y, int metaState) {
    MotionEvent event = obtainFromPool();
    event.mDownTime = downTime;
    event.mEventTime = eventTime;
    event.mAction = action;
    event.mPointerCoords[0].x = x;
    // BUG: Missing y coordinate initialization!
    // event.mPointerCoords[0].y = y;
    event.mMetaState = metaState;
    return event;
}
```

### 正確程式碼
```java
public static MotionEvent obtain(..., float x, float y, ...) {
    MotionEvent event = obtainFromPool();
    event.mDownTime = downTime;
    event.mEventTime = eventTime;
    event.mAction = action;
    event.mPointerCoords[0].x = x;
    event.mPointerCoords[0].y = y;  // Must set Y!
    event.mMetaState = metaState;
    return event;
}
```

### 錯誤數據流分析
```
1. event1 創建: x=100, y=200 (pool object A)
2. event1 回收: object A 回到池中，欄位未清除
3. event2 創建: 從池取出 object A，設定 x=300，y 未更新
4. event2 狀態: x=300, y=200 (殘留值)
```

### 為什麼其他選項不對

**B) recycle() 未加入池**
- 如果未加入池，obtain 會創建新物件
- 新物件的欄位會有默認值（0.0），不是舊事件的值

**C) WeakReference + GC**
- 物件被 GC 回收後會完全消失，不會「部分回收」
- 這種行為在 Java 中不存在

**D) 初始化順序錯誤**
- 如果是順序問題，應該是 Y 設定後被覆蓋
- 但錯誤顯示 Y 是舊值，說明根本沒設定 Y

### 關鍵洞察
物件池模式需要確保重用物件時完整初始化。常見錯誤是在修改 obtain 簽名增加參數時，忘記在實作中使用新參數。防禦性編程應該在 recycle 時清除敏感欄位，或在 obtain 時完整重置。
