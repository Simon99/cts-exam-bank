# Q007: KeyEvent 修飾鍵檢查錯誤

## CTS Test
`android.view.cts.AppKeyCombinationsTest#testShiftModifier`

## Failure Log
```
junit.framework.AssertionFailedError: isShiftPressed() returned wrong value
Expected: true (Shift key is pressed)
Actual: false

at android.view.cts.AppKeyCombinationsTest.testShiftModifier(AppKeyCombinationsTest.java:87)
```

## 現象描述
CTS 測試報告當按住 Shift 鍵時，`KeyEvent.isShiftPressed()` 回傳 false。
鍵盤快捷鍵組合（如 Shift+A）無法正確識別。

## 提示
- 此測試檢查修飾鍵狀態
- `isShiftPressed()` 應該檢查 meta state 中的 Shift 位元
- 問題可能在於位元運算邏輯

## 選項

A) `isShiftPressed()` 中使用 OR (`|`) 而非 AND (`&`) 做位元運算

B) `isShiftPressed()` 中檢查了錯誤的位元遮罩 `META_CTRL_ON` 而非 `META_SHIFT_ON`

C) `isShiftPressed()` 中使用 `!=` 而非 `==` 比較結果

D) `isShiftPressed()` 中直接回傳 `false`
