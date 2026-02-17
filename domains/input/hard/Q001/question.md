# Q001: KeyEvent.dispatch() 狀態恢復錯誤

## CTS Test
`android.view.cts.KeyEventTest#testDispatchMultiple`

## Failure Log
```
junit.framework.AssertionFailedError: KeyEvent state corrupted after dispatch
Event action before dispatch: ACTION_MULTIPLE (2)
Event repeatCount before: 5
Event action after dispatch: ACTION_DOWN (0)  // Should be ACTION_MULTIPLE
Event repeatCount after: 0  // Should be 5

Callback.onKeyMultiple returned: false
Callback.onKeyDown returned: false

at android.view.cts.KeyEventTest.testDispatchMultiple(KeyEventTest.java:456)
```

## 現象描述
CTS 測試報告 `KeyEvent.dispatch()` 處理 `ACTION_MULTIPLE` 事件後，
KeyEvent 對象的狀態（action 和 repeatCount）被錯誤地修改，沒有恢復到原始值。

問題發生在 Callback 回調都返回 false（事件未被處理）的情況下。

## 提示
- `dispatch()` 處理 `ACTION_MULTIPLE` 時會臨時修改事件狀態
- 需要模擬 DOWN/UP 序列給不支援 multiple 的舊版 Callback
- 正確行為：無論是否處理，dispatch 完成後應恢復事件原始狀態

## 選項

A) `ACTION_MULTIPLE` 處理中，狀態恢復邏輯放在 `if (handled)` 分支內，導致未處理時不恢復

B) `ACTION_MULTIPLE` 處理中，先恢復 `mRepeatCount` 再恢復 `mAction`，順序錯誤

C) `ACTION_MULTIPLE` 處理中，使用 `==` 比較 `KEYCODE_UNKNOWN` 而非 `!=`

D) `ACTION_MULTIPLE` 處理中，漏掉調用 `receiver.onKeyUp()` 導致狀態不一致
