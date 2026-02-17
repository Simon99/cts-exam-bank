# Q007: 繪圖平板壓力感應範圍異常

## CTS Test
`android.view.cts.DrawingTabletTest#testStylusPressureRange`

## Failure Log
```
junit.framework.AssertionFailedError: Wrong pressure range returned for stylus
Test: Query pressure range for stylus source on hybrid tablet device

Device configuration:
  - Touchscreen source (SOURCE_TOUCHSCREEN = 0x1002)
    - AXIS_X: 0.0 - 1920.0
    - AXIS_Y: 0.0 - 1080.0
    - AXIS_PRESSURE: 0.0 - 1.0 (binary touch)
    
  - Stylus source (SOURCE_STYLUS = 0x4002)
    - AXIS_X: 0.0 - 1920.0
    - AXIS_Y: 0.0 - 1080.0
    - AXIS_PRESSURE: 0.0 - 4096.0 (high-precision pressure)
    - AXIS_TILT: -1.0 - 1.0

Test query:
  inputDevice.getMotionRange(MotionEvent.AXIS_PRESSURE, InputDevice.SOURCE_STYLUS)

Expected result:
  MotionRange { min=0.0, max=4096.0 }  // Stylus high-precision pressure

Actual result:
  MotionRange { min=0.0, max=1.0 }     // Touchscreen binary pressure!

Additional diagnostics:
  mMotionRanges contents (indexed order):
    [0] axis=AXIS_X, source=SOURCE_TOUCHSCREEN
    [1] axis=AXIS_Y, source=SOURCE_TOUCHSCREEN
    [2] axis=AXIS_PRESSURE, source=SOURCE_TOUCHSCREEN  <-- RETURNED (wrong!)
    [3] axis=AXIS_X, source=SOURCE_STYLUS
    [4] axis=AXIS_Y, source=SOURCE_STYLUS
    [5] axis=AXIS_PRESSURE, source=SOURCE_STYLUS       <-- EXPECTED
    [6] axis=AXIS_TILT, source=SOURCE_STYLUS

at android.view.cts.DrawingTabletTest.testStylusPressureRange(DrawingTabletTest.java:89)
```

## 現象描述
繪圖 App 在混合輸入設備（同時支援觸控和手寫筆）上查詢手寫筆的壓力感應範圍，
卻得到觸控螢幕的壓力範圍。導致高精度壓力感應（0-4096）被當作二元觸控（0-1）處理。

## 提示
- 混合設備同一個軸（如 AXIS_PRESSURE）在不同輸入源有不同的範圍
- `getMotionRange(axis, source)` 需同時比對軸和輸入源
- 注意邏輯運算符的語義差異

## 選項

A) 迴圈中使用 `i <= numRanges` 造成陣列越界，提前返回錯誤結果

B) 條件判斷使用 `||` 而非 `&&`，只要軸匹配就返回，忽略輸入源

C) 遍歷順序相反（從後往前），觸控螢幕條目覆蓋手寫筆條目

D) `range.mSource` 未正確初始化，所有來源比對都失敗，退化為只比對軸
