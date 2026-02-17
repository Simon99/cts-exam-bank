# Q007 Answer

## 正確答案：B

## 解析

### 問題根因
`InputDevice.getMotionRange(int axis, int source)` 的條件判斷使用了 `||`（邏輯或）而非 `&&`（邏輯與），導致方法只要找到軸匹配的第一個 MotionRange 就返回，完全忽略輸入源的匹配。

### Bug 程式碼
```java
public MotionRange getMotionRange(int axis, int source) {
    final int numRanges = mMotionRanges.size();
    for (int i = 0; i < numRanges; i++) {
        final MotionRange range = mMotionRanges.get(i);
        // BUG: || instead of && - returns first axis match regardless of source
        if (range.mAxis == axis || range.mSource == source) {
            return range;
        }
    }
    return null;
}
```

### 正確程式碼
```java
public MotionRange getMotionRange(int axis, int source) {
    final int numRanges = mMotionRanges.size();
    for (int i = 0; i < numRanges; i++) {
        final MotionRange range = mMotionRanges.get(i);
        // Correct: both axis AND source must match
        if (range.mAxis == axis && range.mSource == source) {
            return range;
        }
    }
    return null;
}
```

### 錯誤執行流程
```
查詢: getMotionRange(AXIS_PRESSURE, SOURCE_STYLUS)

mMotionRanges 遍歷:
  [0] axis=AXIS_X, source=TOUCHSCREEN
      -> X != PRESSURE, TOUCHSCREEN != STYLUS -> 都不符合，繼續
  [1] axis=AXIS_Y, source=TOUCHSCREEN
      -> Y != PRESSURE, TOUCHSCREEN != STYLUS -> 都不符合，繼續
  [2] axis=AXIS_PRESSURE, source=TOUCHSCREEN
      -> PRESSURE == PRESSURE ✓ || TOUCHSCREEN != STYLUS
      -> || 短路評估，第一個條件為真，直接返回這個！

結果: 返回 [2]（觸控螢幕壓力範圍），而非 [5]（手寫筆壓力範圍）
```

### 為什麼其他選項不對

**A) 陣列越界 (`i <= numRanges`)**
- 如果越界，會拋出 `IndexOutOfBoundsException`，不是返回錯誤值
- 錯誤日誌沒有顯示任何異常，只是返回了錯誤的 MotionRange

**C) 遍歷順序相反**
- 如果從後往前遍歷，應該先找到手寫筆的條目 [5]、[6] 等
- 錯誤日誌顯示返回的是 [2]（觸控螢幕壓力），這是靠前的位置
- 反向遍歷會得到不同的錯誤結果

**D) source 未初始化**
- 如果 mSource 未初始化，它會是預設值 0
- SOURCE_STYLUS (0x4002) 和 SOURCE_TOUCHSCREEN (0x1002) 都不是 0
- 所有來源比對都會失敗，方法會返回 `null`，而非錯誤的 MotionRange

### 關鍵洞察
`&&` vs `||` 是常見的邏輯運算符混淆錯誤。在這個場景中：
- `&&` 語義：「軸必須匹配 **且** 來源也必須匹配」
- `||` 語義：「只要軸匹配 **或** 來源匹配，任一條件滿足即可」

由於 mMotionRanges 的儲存順序，觸控螢幕的條目先於手寫筆，使用 `||` 會導致查詢任何手寫筆相關的軸時，都可能返回觸控螢幕的範圍（如果該軸在觸控螢幕中存在）。

### 影響範圍
- 繪圖應用無法獲取正確的手寫筆壓力範圍，壓力感應失真
- 遊戲手把的搖桿範圍可能與觸控板混淆
- 任何多源輸入設備的軸範圍查詢都可能出錯
