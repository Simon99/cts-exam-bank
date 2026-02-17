# Q006: KeyEvent 按鍵碼回傳錯誤

## CTS Test
`android.view.cts.InputEventTest#testGetKeyCode`

## Failure Log
```
junit.framework.AssertionFailedError: getKeyCode() returned wrong value
Expected: KEYCODE_A (29)
Actual: KEYCODE_UNKNOWN (0)

at android.view.cts.InputEventTest.testGetKeyCode(InputEventTest.java:312)
```

## 現象描述
CTS 測試報告 `KeyEvent.getKeyCode()` 回傳 `KEYCODE_UNKNOWN (0)`。
當使用者按下 A 鍵時，應該回傳 `KEYCODE_A (29)`。

## 提示
- 此測試檢查按鍵碼是否正確回傳
- KeyEvent 儲存了按鍵相關的所有資訊
- 問題可能在於按鍵碼的讀取

## 選項

A) `getKeyCode()` 中回傳了 `mScanCode` 而非 `mKeyCode`

B) `getKeyCode()` 中回傳固定值 `KEYCODE_UNKNOWN`

C) `getKeyCode()` 中對 `mKeyCode` 做了位元 AND 運算 (`mKeyCode & 0`)

D) `getKeyCode()` 中的成員變數 `mKeyCode` 被錯誤地初始化為 static
