# Q004 Answer: MotionEvent getPressure() 邊界錯誤

## 正確答案
**B) `getPressure()` 中傳給 native 方法的 index 是 `pointerIndex + 1`**

## 問題根因
在 `MotionEvent.java` 的 `getPressure(int pointerIndex)` 函數中，
傳給 native 方法的 index 錯誤地加了 1，導致存取越界。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final float getPressure(int pointerIndex) {
    return nativeGetAxisValue(mNativePtr, AXIS_PRESSURE, pointerIndex + 1, HISTORY_CURRENT);
    // BUG: 當 pointerIndex=1, count=2 時，1+1=2 造成越界
}

// 正確的代碼
public final float getPressure(int pointerIndex) {
    return nativeGetAxisValue(mNativePtr, AXIS_PRESSURE, pointerIndex, HISTORY_CURRENT);
}
```

## 為什麼其他選項不對

**A)** `<= getPointerCount()` 會讓 index=2 通過檢查，但問題發生在 index=1。

**C)** 沒有邊界檢查但傳入正確的 index，native 層會自己做檢查。

**D)** pointer count 減半會讓 index 1 超出範圍 0，但錯誤訊息顯示 length=2。

## 相關知識
- 陣列越界是常見的 off-by-one 錯誤
- Native 層會嚴格檢查邊界並拋出異常
- 壓力值範圍通常是 0.0 到 1.0

## 難度說明
**Medium** - 需要分析 index=1 如何變成 index=2，推算出 +1 的 bug。
