# Q002: MotionEvent getActionIndex() 計算錯誤

## CTS Test
`android.view.cts.TouchScreenTest#testActionIndex`

## Failure Log
```
junit.framework.AssertionFailedError: getActionIndex() returned wrong value
Expected: 1 (second pointer index)
Actual: 256

at android.view.cts.TouchScreenTest.testActionIndex(TouchScreenTest.java:218)
```

## 現象描述
CTS 測試報告 `MotionEvent.getActionIndex()` 回傳 256 而非預期的 1。
多點觸控事件無法正確識別是哪個觸控點觸發的動作。

## 提示
- `getActionIndex()` 應該取出 action 高 8 位中的 pointer index
- `ACTION_POINTER_INDEX_SHIFT` 為 8
- 問題在於位元運算

## 選項

A) `getActionIndex()` 中使用 `<< ACTION_POINTER_INDEX_SHIFT` 而非 `>> ACTION_POINTER_INDEX_SHIFT`

B) `getActionIndex()` 中先做 AND 遮罩再右移，順序正確但遮罩值錯誤

C) `getActionIndex()` 中只做了 AND 遮罩沒有右移

D) `getActionIndex()` 中使用 `mAction % 256` 計算
