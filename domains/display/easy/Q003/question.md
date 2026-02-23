# Question DIS-E003

## CTS 測試資訊
- **Module**: CtsDisplayTestCases
- **Test**: android.display.cts.DisplayTest#testGetMetrics
- **失敗類型**: AssertionError

## 測試失敗訊息

```
junit.framework.AssertionFailedError: expected:<214> but was:<215>
	at android.display.cts.DisplayTest.testGetMetrics(DisplayTest.java:XXX)
```

## 相關日誌

```
02-20 10:40:30.789 D/DisplayManagerService: Creating overlay display device: 181x161/214
02-20 10:40:30.791 D/OverlayDisplayAdapter: getDisplayDeviceInfoLocked: densityDpi=215, xDpi=215, yDpi=215
02-20 10:40:30.795 I/DisplayTest: DisplayMetrics.densityDpi: 215, expected: 214
```

## 問題描述

CTS 測試 `testGetMetrics` 驗證 overlay display 的顯示密度（DPI）是否正確。測試預期密度為 214 DPI，但實際回報的密度為 215 DPI。

這個 1 DPI 的差異表示在設置密度相關屬性時存在計算錯誤。

## 任務

1. 找出導致 DPI 值多 1 的程式碼錯誤
2. 修復該錯誤，使 overlay display 正確回報密度
3. 確保 xDpi 和 yDpi 也被正確設置
