# Q005 Answer: MotionEvent 軸值取得失敗

## 正確答案
**B) `getAxisValue()` 中沒有呼叫 native 方法，直接回傳 0.0f**

## 問題根因
在 `MotionEvent.java` 的 `getAxisValue()` 函數中，
沒有呼叫 native 方法取得實際軸值，而是直接回傳 0.0f。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final float getAxisValue(int axis) {
    return 0.0f;  // BUG: 直接回傳 0
}

// 正確的代碼
public final float getAxisValue(int axis) {
    return nativeGetAxisValue(mNativePtr, axis, 0, HISTORY_CURRENT);
}
```

## 為什麼其他選項不對

**A)** 參數順序錯誤會導致取得錯誤的值，但不太可能剛好是 0.0。

**C)** 使用錯誤的 axis 常數會取得 X 座標值，不會是 0.0。

**D)** `AXIS_PRESSURE` 的常數值是 24（大於 0），所以 `> 0` 的判斷也會通過。

## 相關知識
- MotionEvent 的軸值系統 (AXIS_X, AXIS_Y, AXIS_PRESSURE, etc.)
- 不同輸入裝置支援的軸不同（觸控筆有更多軸）
- 軸值的有效範圍依軸類型而定

## 難度說明
**Easy** - 回傳固定值 0.0 是最簡單的 bug，從 log 可直接判斷。
