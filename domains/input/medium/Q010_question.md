# Q010: InputDevice supportsSource() 檢查錯誤

## CTS Test
`android.view.cts.InputEventTest#testSupportsSource`

## Failure Log
```
junit.framework.AssertionFailedError: supportsSource() returned wrong value
Expected: true (device supports SOURCE_TOUCHSCREEN)
Actual: false

Device sources: 0x00001002 (SOURCE_TOUCHSCREEN)
Checked source: 0x00001002
at android.view.cts.InputEventTest.testSupportsSource(InputEventTest.java:156)
```

## 現象描述
CTS 測試報告 `InputDevice.supportsSource(SOURCE_TOUCHSCREEN)` 回傳 false。
觸控螢幕設備的 sources 包含 `SOURCE_TOUCHSCREEN`，但 `supportsSource()` 無法正確識別。

## 提示
- `supportsSource()` 應該檢查設備的 sources 是否包含指定的 source
- source 值是位元旗標
- 問題可能在於位元運算邏輯

## 選項

A) `supportsSource()` 中使用 `sources | source` 而非 `sources & source`

B) `supportsSource()` 中使用 `==` 比較而非 `!=` 與 0 比較

C) `supportsSource()` 中的比較結果取反 (`!`)

D) `supportsSource()` 中使用 `~source` (位元反轉) 做遮罩
