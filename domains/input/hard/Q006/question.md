# Q006: 多點觸控事件一致性驗證失敗

## CTS Test
`android.view.cts.TouchScreenTest#testMultiTouchConsistency`

## Failure Log
```
junit.framework.AssertionFailedError: Touch event stream consistency check failed
Test scenario: Two-finger pinch gesture on touchscreen

Event sequence:
  1. ACTION_DOWN (pointer 0) - OK
  2. ACTION_POINTER_DOWN (pointer 1) - OK
  3. ACTION_MOVE (both pointers) - FAILED

InputEventConsistencyVerifier error:
  "ACTION_MOVE contained 2 pointers but there are currently 1 pointers down."

Debug trace:
  After ACTION_DOWN: mTouchEventStreamPointers = 0b00000001 (pointer 0)
  After ACTION_POINTER_DOWN: mTouchEventStreamPointers = 0b00000010 (pointer 1 only!)
  Expected: mTouchEventStreamPointers = 0b00000011 (both pointers)

Pointer tracking bitmap was overwritten instead of being updated.

at android.view.cts.TouchScreenTest.testMultiTouchConsistency(TouchScreenTest.java:456)
```

## 現象描述
CTS 測試發現在雙指手勢時，InputEventConsistencyVerifier 報告 pointer 數量不一致。
第二隻手指按下時，第一隻手指的追蹤狀態似乎丟失了。

## 提示
- InputEventConsistencyVerifier 使用 bitmap 追蹤目前按下的 pointer
- 每個 pointer id 對應 bitmap 中的一個 bit
- ACTION_POINTER_DOWN 應該將新 pointer 加入追蹤

## 選項

A) ACTION_POINTER_DOWN 處理時使用 `=` 覆蓋了 bitmap，而不是用 `|=` 加入新 bit

B) ACTION_DOWN 處理時忘記初始化 bitmap，導致殘留舊狀態

C) pointer id 計算使用 `1 >> id` 而非 `1 << id`，導致 bit 位置錯誤

D) ACTION_POINTER_UP 處理時用 `|=` 而非 `&= ~`，導致 bit 無法清除
