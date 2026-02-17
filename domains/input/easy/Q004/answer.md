# Q004 Answer: MotionEvent 歷史大小回傳錯誤

## 正確答案
**A) `getHistorySize()` 中使用 `historySize - 1` 回傳**

## 問題根因
在 `MotionEvent.java` 的 `getHistorySize()` 函數中，
回傳值錯誤地減去 1，導致歷史大小少報一個。

## Bug 位置
`frameworks/base/core/java/android/view/MotionEvent.java`

## 修復方式
```java
// 錯誤的代碼
public final int getHistorySize() {
    return nativeGetHistorySize(mNativePtr) - 1;  // BUG: 減 1
}

// 正確的代碼
public final int getHistorySize() {
    return nativeGetHistorySize(mNativePtr);
}
```

## 為什麼其他選項不對

**B)** 右移 1 位相當於除以 2，5 >> 1 = 2，不是 4。

**C)** `5/2 + 5/2 = 2 + 2 = 4`，數學上正確但這種寫法太不自然。

**D)** 迴圈計數問題會在計數過程中出錯，但 `getHistorySize()` 通常直接從 native 取值。

## 相關知識
- MotionEvent 歷史事件的批次處理 (batching)
- 歷史資料用於平滑繪圖和動畫
- 每次 dispatch 可能包含多個歷史樣本

## 難度說明
**Easy** - 差 1 的錯誤最常見的原因就是 off-by-one，直接減 1 是最直觀的 bug。
