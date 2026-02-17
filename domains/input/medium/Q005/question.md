# Q005: MotionEvent getToolType() 判斷錯誤

## CTS Test
`android.view.cts.SimultaneousTouchAndStylusTest#testToolType`

## Failure Log
```
junit.framework.AssertionFailedError: getToolType() returned wrong value
Expected: TOOL_TYPE_STYLUS (2) for stylus input
Actual: TOOL_TYPE_FINGER (1)

at android.view.cts.SimultaneousTouchAndStylusTest.testToolType(SimultaneousTouchAndStylusTest.java:89)
```

## 現象描述
CTS 測試報告使用手寫筆時，`MotionEvent.getToolType()` 回傳 `TOOL_TYPE_FINGER`。
系統無法正確區分手指觸控和手寫筆輸入。

## 提示
- `getToolType(int pointerIndex)` 應該回傳該觸控點的工具類型
- 工具類型：FINGER=1, STYLUS=2, MOUSE=3, ERASER=4
- 問題可能在於回傳值的邏輯

## 選項

A) `getToolType()` 中的 switch-case 對於 stylus 誤 fallthrough 到 finger

B) `getToolType()` 中直接回傳 `TOOL_TYPE_FINGER` 作為預設值

C) `getToolType()` 中判斷 stylus 的條件 `source == SOURCE_STYLUS` 寫成 `!=`

D) `getToolType()` 中將 TOOL_TYPE_STYLUS 常數值定義錯誤
