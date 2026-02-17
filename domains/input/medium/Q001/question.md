# Q001: MotionEvent getActionMasked() 遮罩錯誤

## CTS Test
`android.view.cts.TouchScreenTest#testActionMasked`

## Failure Log
```
junit.framework.AssertionFailedError: getActionMasked() returned wrong value
Expected: ACTION_POINTER_DOWN (5)
Actual: 261 (ACTION_POINTER_DOWN | pointer_index << 8)

at android.view.cts.TouchScreenTest.testActionMasked(TouchScreenTest.java:203)
```

## 現象描述
CTS 測試報告 `MotionEvent.getActionMasked()` 回傳的值包含了 pointer index。
多點觸控第二指按下時，應該回傳純 `ACTION_POINTER_DOWN (5)`，
但回傳了 261 (= 5 | (1 << 8))。

## 提示
- `getActionMasked()` 應該只回傳動作類型（低 8 位）
- `ACTION_MASK` 的值為 0xFF
- 問題在於位元遮罩運算

## 選項

A) `getActionMasked()` 中使用 `mAction | ACTION_MASK` 而非 `mAction & ACTION_MASK`

B) `getActionMasked()` 中直接回傳 `mAction` 而沒有做遮罩運算

C) `getActionMasked()` 中使用 `mAction & ~ACTION_MASK` (反向遮罩)

D) `getActionMasked()` 中的 `ACTION_MASK` 常數值定義為 0xFFFF 而非 0xFF
