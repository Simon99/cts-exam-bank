# Q003 Answer: MotionEvent 觸控點數錯誤

## 正確答案
**C) `getPointerCount()` 中將 native 回傳值除以 2**

## 問題根因
在 `MotionEvent.java` 的 `getPointerCount()` 函數中，
native 方法回傳的觸控點數被錯誤地除以 2。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getPointerCount() {
    return nativeGetPointerCount(mNativePtr) / 2;  // BUG: 除以 2
}

// 正確的代碼
public final int getPointerCount() {
    return nativeGetPointerCount(mNativePtr);
}
```

## 為什麼其他選項不對

**A)** 計數器初始化問題會導致每次都多 1，但這裡是少 1（2 變 1）。

**B)** `Math.max(1, count)` 會保證最小值為 1，但不會把 2 變成 1。

**D)** 減 1 的話，2 個觸控點會變成 1，但這裡的 bug 是除以 2，
兩者在這個案例結果相同，但除以 2 更符合「不分觸控點數都減半」的特徵。

## 相關知識
- Android 多點觸控 (Multi-touch) 架構
- pointer count 代表同時觸控的手指數量
- 不同觸控事件（ACTION_POINTER_DOWN/UP）如何影響 pointer count

## 難度說明
**Easy** - 從 log 可以直接看出數量減半，檢查回傳邏輯即可。
