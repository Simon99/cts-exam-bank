# Q005 Answer: MotionEvent getToolType() 判斷錯誤

## 正確答案
**B) `getToolType()` 中直接回傳 `TOOL_TYPE_FINGER` 作為預設值**

## 問題根因
在 `MotionEvent.java` 的 `getToolType()` 函數中，
沒有呼叫 native 方法取得實際工具類型，而是直接回傳 `TOOL_TYPE_FINGER`。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getToolType(int pointerIndex) {
    return TOOL_TYPE_FINGER;  // BUG: 直接回傳 FINGER
}

// 正確的代碼
public final int getToolType(int pointerIndex) {
    return nativeGetToolType(mNativePtr, pointerIndex);
}
```

## 為什麼其他選項不對

**A)** switch-case fallthrough 通常會在多個 case 使用相同處理時發生，
但這裡是「總是」回傳 FINGER，不是條件性的。

**C)** 如果是 `!=` 的判斷錯誤，stylus 輸入會回傳 FINGER，
但其他輸入（如 finger）可能會回傳 STYLUS，測試會有不同錯誤。

**D)** 常數值錯誤是編譯時問題，且從 log 看 FINGER=1, STYLUS=2 是正確的。

## 相關知識
- Android 支援多種輸入工具：手指、手寫筆、滑鼠、橡皮擦
- 繪圖應用程式需要區分工具類型以實現不同功能
- 同時支援觸控和手寫筆的設備需要正確識別

## 難度說明
**Medium** - 需要理解工具類型的概念和判斷邏輯。
