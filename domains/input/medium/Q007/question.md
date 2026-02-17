# Q007: KeyEvent getMetaState() 修飾鍵狀態錯誤

## CTS Test
`android.view.cts.ModifierKeyRemappingTest#testMetaState`

## Failure Log
```
junit.framework.AssertionFailedError: getMetaState() returned wrong value
Expected: META_SHIFT_ON | META_CTRL_ON (0x41)
Actual: META_SHIFT_ON (0x01)

at android.view.cts.ModifierKeyRemappingTest.testMetaState(ModifierKeyRemappingTest.java:78)
```

## 現象描述
CTS 測試報告同時按下 Shift+Ctrl 時，`KeyEvent.getMetaState()` 只回傳 Shift 狀態。
鍵盤組合快捷鍵無法正確識別多個修飾鍵。

## 提示
- `getMetaState()` 應該回傳所有按下的修飾鍵的位元組合
- META_SHIFT_ON = 0x01, META_CTRL_ON = 0x40
- 問題可能在於狀態位元的處理

## 選項

A) `getMetaState()` 中使用 `mMetaState & META_SHIFT_ON` 只取 Shift 位元

B) `getMetaState()` 中使用 `mMetaState | 0` 而非直接回傳

C) `getMetaState()` 中將 meta state 右移造成 Ctrl 位元被截斷

D) `getMetaState()` 中的 META_CTRL_ON 常數值定義為 0 而非 0x40
