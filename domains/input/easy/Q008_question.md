# Q008: KeyEvent 重複次數計算錯誤

## CTS Test
`android.view.cts.InputEventTest#testRepeatCount`

## Failure Log
```
junit.framework.AssertionFailedError: getRepeatCount() returned wrong value
Expected: 5 (key held for 5 repeats)
Actual: 0

at android.view.cts.InputEventTest.testRepeatCount(InputEventTest.java:178)
```

## 現象描述
CTS 測試報告當按住按鍵產生 5 次重複事件時，`KeyEvent.getRepeatCount()` 回傳 0。
長按按鍵的重複計數功能失效。

## 提示
- 此測試檢查按鍵重複計數
- 長按按鍵會產生多個帶有遞增 repeat count 的事件
- 問題可能在於計數值的回傳

## 選項

A) `getRepeatCount()` 中對 `mRepeatCount` 取絕對值 `Math.abs()`

B) `getRepeatCount()` 中使用模運算 `mRepeatCount % 1`

C) `getRepeatCount()` 中直接回傳 0

D) `getRepeatCount()` 中使用位元右移 `mRepeatCount >> 8`
