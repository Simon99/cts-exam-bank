# Q002 Answer: MotionEvent 座標取得錯誤

## 正確答案
**B) `getX()` 中使用了錯誤的 pointer index (傳入 1 而非 0)**

## 問題根因
在 `MotionEvent.java` 的 `getX()` 函數中，呼叫 `getX(int pointerIndex)` 時
傳入了 pointer index 1 而非 0，導致存取了不存在的第二個觸控點。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final float getX() {
    return nativeGetAxisValue(mNativePtr, AXIS_X, 1, HISTORY_CURRENT);  // BUG: 應該是 0
}

// 正確的代碼
public final float getX() {
    return nativeGetAxisValue(mNativePtr, AXIS_X, 0, HISTORY_CURRENT);
}
```

## 為什麼其他選項不對

**A)** 強制轉型會造成精度損失，但不會導致座標變成 0.0。

**C)** MotionEvent 使用 native 方法取得座標，沒有 `mX` 成員變數。

**D)** 如果忘記傳入參數，編譯時就會報錯，不會通過編譯。

## 相關知識
- MotionEvent 多點觸控的 pointer index 概念
- 無參數 `getX()` 等同於 `getX(0)`，取得第一個觸控點
- pointer index 從 0 開始計數

## 難度說明
**Easy** - 從回傳 0.0 可以推測是存取了不存在的資料，檢查索引參數即可。
