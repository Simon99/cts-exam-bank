# Q002 Answer: InputDevice getMotionRange() 多源設備錯誤

## 正確答案
**A) `getMotionRange()` 中忽略 source 參數，總是回傳第一個找到的 range**

## 問題根因
在 `InputDevice.java` 的 `getMotionRange(int axis, int source)` 函數中，
source 參數被忽略，導致總是回傳第一個匹配 axis 的 MotionRange。

## Bug 位置
`frameworks/base/core/java/android/view/InputDevice.java`

## 修復方式
```java
// 錯誤的代碼
public MotionRange getMotionRange(int axis, int source) {
    for (MotionRange range : mMotionRanges) {
        if (range.mAxis == axis) {  // BUG: 沒有檢查 source
            return range;
        }
    }
    return null;
}

// 正確的代碼
public MotionRange getMotionRange(int axis, int source) {
    for (MotionRange range : mMotionRanges) {
        if (range.mAxis == axis && range.mSource == source) {
            return range;
        }
    }
    return null;
}
```

## 為什麼其他選項不對

**B)** `|` 會讓任何 source 都匹配，但結果會是隨機的，不一定是 touchscreen。

**C)** 順序問題需要在有正確 source 檢查的前提下才有意義。

**D)** 把 source 當 axis 會查詢錯誤的軸，不太可能剛好回傳 PRESSURE 的 range。

## 相關知識
- InputDevice 可以有多個輸入源 (SOURCE_TOUCHSCREEN, SOURCE_STYLUS, etc.)
- 每個 source 的同一個 axis 可能有不同的特性（解析度、範圍）
- 繪圖應用程式需要知道手寫筆的壓力精度

## 難度說明
**Hard** - 需要理解多源設備架構，分析為何取得錯誤 source 的資料。
