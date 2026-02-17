# Q006 Answer: MotionEvent getHistoricalX() 歷史座標錯誤

## 正確答案
**B) `getHistoricalX()` 中忽略 `pos` 參數，總是傳入 0**

## 問題根因
在 `MotionEvent.java` 的 `getHistoricalX()` 函數中，
傳給 native 方法的 `pos` 參數被硬編碼為 0，導致總是取得第一個歷史位置。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final float getHistoricalX(int pointerIndex, int pos) {
    return nativeGetAxisValue(mNativePtr, AXIS_X, pointerIndex, 0);  // BUG: 應該是 pos
}

// 正確的代碼
public final float getHistoricalX(int pointerIndex, int pos) {
    return nativeGetAxisValue(mNativePtr, AXIS_X, pointerIndex, pos);
}
```

## 為什麼其他選項不對

**A)** 交換 `pos` 和 `pointerIndex` 會導致不同的錯誤行為，可能越界。

**C)** `pos % 1` 結果永遠是 0，這和選項 B 效果相同，但寫法太刻意。

**D)** `pos` 是整數，轉型為 float 不會影響整數值 0, 1, 2 的正確傳遞。

## 相關知識
- MotionEvent 歷史資料的結構
- 歷史樣本用於高精度繪圖和手勢識別
- `getHistorySize()` 取得歷史大小，`pos` 範圍是 `[0, historySize-1]`

## 難度說明
**Medium** - 需要理解歷史座標的存取方式，分析為何總是得到相同結果。
