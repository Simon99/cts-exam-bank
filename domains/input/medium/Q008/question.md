# Q008: KeyEvent keyCodeFromString() 解析錯誤

## CTS Test
`android.view.cts.InputEventTest#testKeyCodeFromString`

## Failure Log
```
junit.framework.AssertionFailedError: keyCodeFromString() returned wrong value
Expected: KEYCODE_A (29)
Actual: KEYCODE_UNKNOWN (0)

Input: "KEYCODE_A"
at android.view.cts.InputEventTest.testKeyCodeFromString(InputEventTest.java:289)
```

## 現象描述
CTS 測試報告 `KeyEvent.keyCodeFromString("KEYCODE_A")` 回傳 `KEYCODE_UNKNOWN`。
字串形式的按鍵碼無法正確轉換為對應的整數值。

## 提示
- `keyCodeFromString()` 應該將 "KEYCODE_X" 格式字串轉換為對應的按鍵碼整數
- 此函數需要處理 "KEYCODE_" 前綴
- 問題可能在於前綴判斷邏輯

## 選項

A) `keyCodeFromString()` 中使用 `endsWith()` 而非 `startsWith()` 判斷前綴

B) `keyCodeFromString()` 中 substring 切割長度計算錯誤

C) `keyCodeFromString()` 中 LABEL_PREFIX 常數定義錯誤

D) `keyCodeFromString()` 中 nativeKeyCodeFromString() 呼叫前少了 toLowerCase()
