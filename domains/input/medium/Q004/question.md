# Q004: MotionEvent getPressure() 邊界錯誤

## CTS Test
`android.view.cts.TouchScreenTest#testGetPressure`

## Failure Log
```
java.lang.ArrayIndexOutOfBoundsException: length=2; index=2
at android.view.MotionEvent.nativeGetAxisValue(Native Method)
at android.view.MotionEvent.getPressure(MotionEvent.java:2298)
at android.view.cts.TouchScreenTest.testGetPressure(TouchScreenTest.java:267)
```

## 現象描述
CTS 測試報告呼叫 `MotionEvent.getPressure(pointerIndex)` 時發生陣列越界。
當有 2 個觸控點時，取得 index 1 的壓力值會失敗。

## 提示
- `getPressure(int pointerIndex)` 需要驗證 pointerIndex 的有效性
- 合法的 pointerIndex 範圍是 `[0, getPointerCount()-1]`
- 問題可能在於邊界檢查

## 選項

A) `getPressure()` 中的邊界檢查 `pointerIndex < getPointerCount()` 寫成 `pointerIndex <= getPointerCount()`

B) `getPressure()` 中傳給 native 方法的 index 是 `pointerIndex + 1`

C) `getPressure()` 中沒有做任何邊界檢查就直接呼叫 native 方法

D) `getPressure()` 中的 `getPointerCount()` 被錯誤地除以 2
