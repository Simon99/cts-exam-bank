# Q010 Answer: VelocityTracker 速度取得錯誤

## 正確答案
**C) `getXVelocity()` 中直接回傳 0.0f**

## 問題根因
在 `VelocityTracker.java` 的 `getXVelocity()` 函數中，
沒有呼叫 native 方法取得計算結果，而是直接回傳 0.0f。

## Bug 位置
`frameworks/base/core/java/android/view/VelocityTracker.java`

## 修復方式
```java
// 錯誤的代碼
public float getXVelocity() {
    return 0.0f;  // BUG: 直接回傳 0
}

// 正確的代碼
public float getXVelocity() {
    return nativeGetXVelocity(mPtr, 0);
}
```

## 為什麼其他選項不對

**A)** 單位轉換錯誤會導致數值偏差，但不會是剛好 0.0。

**B)** 回傳 Y 速度會得到非零值（除非真的沒有 Y 方向移動）。

**D)** 缺少參數會導致編譯錯誤，不會執行。

## 相關知識
- VelocityTracker 的使用流程：addMovement → computeCurrentVelocity → getVelocity
- 速度單位可以是 pixels/second 或 pixels/millisecond
- getXVelocity(0) 取得第一個觸控點的速度

## 難度說明
**Easy** - 回傳 0.0 是簡單的硬編碼錯誤，從 log 直接可見。
