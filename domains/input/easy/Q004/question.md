# Q004: MotionEvent 歷史大小回傳錯誤

## CTS Test
`android.view.cts.MotionEventIsResampledTest#testHistorySize`

## Failure Log
```
junit.framework.AssertionFailedError: getHistorySize() returned wrong value
Expected: 5 (after batching 5 motion events)
Actual: 4

at android.view.cts.MotionEventIsResampledTest.testHistorySize(MotionEventIsResampledTest.java:78)
```

## 現象描述
CTS 測試報告 `MotionEvent.getHistorySize()` 回傳值比預期少 1。
當系統批次處理 5 個 motion 事件後，歷史大小應為 5，但回傳 4。

## 提示
- 此測試檢查 MotionEvent 的歷史事件批次處理
- `getHistorySize()` 回傳歷史樣本的數量
- 問題可能在於計數方式

## 選項

A) `getHistorySize()` 中使用 `historySize - 1` 回傳

B) `getHistorySize()` 中將歷史大小右移 1 位 (`>> 1`)

C) `getHistorySize()` 中誤用 `historySize / 2 + historySize / 2` 計算

D) `getHistorySize()` 中的迴圈計數從 1 開始而非 0
