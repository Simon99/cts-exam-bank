# Q009 Answer: VelocityTracker computeCurrentVelocity() 單位錯誤

## 正確答案
**B) `computeCurrentVelocity()` 中忽略 units 參數，使用硬編碼的值 1**

## 問題根因
在 `VelocityTracker.java` 的 `computeCurrentVelocity()` 函數中，
傳給 native 方法的 units 參數被硬編碼為 1，忽略了使用者傳入的值。

## Bug 位置
`frameworks/base/core/java/android/view/VelocityTracker.java`

## 修復方式
```java
// 錯誤的代碼
public void computeCurrentVelocity(int units) {
    nativeComputeCurrentVelocity(mPtr, 1, Float.MAX_VALUE);  // BUG: 應該是 units
}

// 正確的代碼
public void computeCurrentVelocity(int units) {
    nativeComputeCurrentVelocity(mPtr, units, Float.MAX_VALUE);
}
```

## 為什麼其他選項不對

**A)** 除以 1000 會讓 1000 變成 1，確實可能造成這個結果，
但「硬編碼為 1」更直接。

**C)** 將 int 轉為 float 不會造成 1000 變成 1 的問題。

**D)** 乘除順序錯誤會導致數量級變化，但不會剛好變成 1/1000。

## 相關知識
- VelocityTracker 速度單位換算
- pixels/millisecond vs pixels/second
- 手勢辨識通常使用 pixels/second

## 難度說明
**Medium** - 需要理解 units 參數的作用，分析數值差異 1000 倍。
