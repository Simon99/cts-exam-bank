# Q003: MotionEvent getActionIndex() 回傳異常值

## CTS Test
`android.view.cts.TouchScreenTest#testMultiTouchPointerIndex`

## Failure Log
```
junit.framework.AssertionFailedError: getActionIndex() returned unexpected value
Expected: 1 (second pointer at index 1)
Actual: 65536 (0x10000)

at android.view.cts.TouchScreenTest.testMultiTouchPointerIndex(TouchScreenTest.java:312)
```

## 現象描述
多點觸控測試中，當第二根手指放下觸發 `ACTION_POINTER_DOWN` 時，
`getActionIndex()` 應該回傳 1（表示第二個觸控點），
但實際回傳了 65536（0x10000），導致後續無法正確識別哪個觸控點發生了變化。

## 提示
- `getActionIndex()` 需要從 action 中提取 pointer index
- action 的高 8 位編碼了 pointer index
- 正確的做法是用 mask 後右移提取值

## 選項

A) `getActionIndex()` 中使用 `ACTION_MASK` 而非 `ACTION_POINTER_INDEX_MASK`

B) `getActionIndex()` 中使用左移 `<<` 而非右移 `>>`

C) `getActionIndex()` 中的 shift 位數錯誤（應為 8，實際用了 16）

D) `getActionIndex()` 中缺少了 mask 運算，直接對整個 action 做右移
