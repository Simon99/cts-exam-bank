# Q003: MotionEvent 觸控點數錯誤

## CTS Test
`android.view.cts.TouchScreenTest#testPointerCount`

## Failure Log
```
junit.framework.AssertionFailedError: getPointerCount() returned wrong value
Expected: 2 (two finger touch)
Actual: 1

at android.view.cts.TouchScreenTest.testPointerCount(TouchScreenTest.java:156)
```

## 現象描述
CTS 測試報告當兩指觸控時，`MotionEvent.getPointerCount()` 只回傳 1。
多點觸控的應用程式無法正確識別觸控點數量。

## 提示
- 此測試檢查多點觸控的觸控點數
- `getPointerCount()` 應該回傳目前的觸控點數量
- 問題出在計數值的回傳

## 選項

A) `getPointerCount()` 中的計數器初始化為 1 而非 0，導致計算偏移

B) `getPointerCount()` 中誤用 `Math.max(1, mPointerCount)` 限制最小值

C) `getPointerCount()` 中將 native 回傳值除以 2

D) `getPointerCount()` 回傳時使用了 `mPointerCount - 1` 而非 `mPointerCount`
