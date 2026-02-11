# Q001: MotionEvent getAction() 回傳錯誤

## CTS Test
`android.view.cts.InputEventTest#testGetAction`

## Failure Log
```
junit.framework.AssertionFailedError: getAction() returned wrong value
Expected: ACTION_DOWN (0)
Actual: ACTION_UP (1)

at android.view.cts.InputEventTest.testGetAction(InputEventTest.java:142)
```

## 現象描述
CTS 測試報告 `MotionEvent.getAction()` 回傳了錯誤的動作碼。
當使用者觸碰螢幕時，理論上應該回傳 `ACTION_DOWN`，但卻回傳了 `ACTION_UP`。

## 提示
- 此測試檢查 MotionEvent 的動作碼是否正確回傳
- 動作碼定義在 MotionEvent 類別的常數中
- 問題出在動作碼的回傳邏輯

## 選項

A) `getAction()` 中的 `return mAction;` 被錯誤地寫成 `return ACTION_UP;`

B) `getAction()` 中的位元遮罩運算 `mAction & ACTION_MASK` 少了遮罩操作

C) `getAction()` 回傳時誤用了 `~mAction` (位元反轉)

D) `getAction()` 中的 `ACTION_DOWN` 常數值定義錯誤
