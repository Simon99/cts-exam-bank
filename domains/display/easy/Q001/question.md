# Question DIS-E001

## CTS 測試資訊
- **Module**: CtsDisplayTestCases
- **Test**: android.display.cts.DisplayTest#testGetDisplayAttrs
- **失敗類型**: AssertionError

## 測試失敗訊息

```
junit.framework.AssertionFailedError: expected:<181> but was:<182>
	at android.display.cts.DisplayTest.testGetDisplayAttrs(DisplayTest.java:XXX)
```

## 相關日誌

```
02-20 10:30:15.123 D/DisplayManagerService: Creating overlay display device: 181x161/214
02-20 10:30:15.125 D/OverlayDisplayAdapter: getDisplayDeviceInfoLocked: width=182, height=161
02-20 10:30:15.130 I/DisplayTest: Secondary display width: 182, expected: 181
```

## 問題描述

CTS 測試 `testGetDisplayAttrs` 驗證 overlay display 的屬性是否正確。測試預期次級顯示器寬度為 181 像素，但實際回報的寬度為 182 像素。

這個差異暗示在設置顯示器屬性時發生了 off-by-one 錯誤。

## 任務

1. 找出導致寬度多出 1 像素的程式碼錯誤
2. 修復該錯誤，使 overlay display 正確回報寬度
3. 確保修改不影響其他顯示器屬性
