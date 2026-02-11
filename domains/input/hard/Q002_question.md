# Q002: InputDevice getMotionRange() 多源設備錯誤

## CTS Test
`android.view.cts.DrawingTabletTest#testMotionRangeBySource`

## Failure Log
```
junit.framework.AssertionFailedError: getMotionRange(AXIS_PRESSURE, SOURCE_STYLUS) wrong
Expected: MotionRange(min=0.0, max=1.0, resolution=1024)  // Stylus pressure
Actual: MotionRange(min=0.0, max=1.0, resolution=1)       // Touchscreen pressure

Device supports: SOURCE_TOUCHSCREEN | SOURCE_STYLUS
at android.view.cts.DrawingTabletTest.testMotionRangeBySource(DrawingTabletTest.java:89)
```

## 現象描述
CTS 測試報告繪圖平板的 `getMotionRange(AXIS_PRESSURE, SOURCE_STYLUS)` 回傳了
觸控螢幕的 resolution=1 而非手寫筆的 resolution=1024。
同時支援觸控和手寫筆的設備，無法取得正確的手寫筆壓力解析度。

## 提示
- `getMotionRange(int axis, int source)` 應該根據 source 回傳對應的 range
- 設備可能有多個 source，每個 source 有不同的 MotionRange
- 問題在於 source 參數的處理

## 選項

A) `getMotionRange()` 中忽略 source 參數，總是回傳第一個找到的 range

B) `getMotionRange()` 中使用 `|` 而非 `&` 檢查 source 匹配

C) `getMotionRange()` 中的 source 比較順序導致 touchscreen 優先於 stylus

D) `getMotionRange()` 中將 source 參數當作 axis 參數使用
