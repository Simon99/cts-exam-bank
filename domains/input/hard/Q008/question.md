# Q008: MotionEvent split() 歷史事件丟失

## CTS Test
`android.view.cts.TouchScreenTest#testMultiTouchSplitEventPreservesHistory`

## Failure Log
```
junit.framework.AssertionFailedError: Split event missing historical data

Original event:
  historySize=5, pointers=[0,1,2]
  eventTime=102345678

Split event (idBits=0x01, pointer 0 only):
  historySize=5  // Correct
  eventTime=0    // ERROR: Should be 102345678!

Expected: Split event eventTime matches original
Actual: Split event eventTime is 0 (uninitialized)

at android.view.cts.TouchScreenTest.testMultiTouchSplitEventPreservesHistory(TouchScreenTest.java:892)
```

## 現象描述
在多點觸控情境下，`MotionEvent.split()` 用於將包含多個 pointer 的事件分割成只包含部分 pointer 的子事件。CTS 測試發現，分割後的事件雖然保留了完整的歷史記錄數量，但**當前事件**的時間戳和座標異常（為 0 或預設值）。

歷史記錄 (pos 0 ~ historySize-1) 的資料都正確，唯獨**最新的當前幀**資料遺失。

## 背景知識
```java
// MotionEvent 內部結構
// 歷史記錄: pos 0 到 historySize-1 (較舊的事件)
// 當前事件: 特殊位置 HISTORY_CURRENT (-1)

// split() 需要複製:
// 1. 所有歷史事件 (h = 0 to historySize-1)
// 2. 當前事件 (h = historySize → 使用 HISTORY_CURRENT)
```

## 提示
- `split()` 使用迴圈遍歷所有歷史記錄並複製到新事件
- 迴圈的終止條件決定了哪些資料被複製
- `HISTORY_CURRENT` 是特殊值，用於存取當前（最新）事件資料

## 選項

A) `split()` 中 `nativeAddBatch()` 的第一個參數傳錯，導致歷史記錄覆蓋了當前事件

B) 迴圈條件 `h < historySize` 漏掉了最後一次迭代，`HISTORY_CURRENT` 的資料未被複製

C) `initialize()` 被呼叫時使用了錯誤的 `historyPos` 參數，導致初始化使用舊資料

D) `eventTimeNanos` 變數在迴圈外宣告但未初始化，導致第一次使用時為預設值 0
