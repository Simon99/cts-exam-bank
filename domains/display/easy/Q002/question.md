# Question DIS-E002

## CTS 測試資訊
- **Module**: CtsDisplayTestCases
- **Test**: android.display.cts.DisplayTest#testGetDisplayAttrs
- **失敗類型**: AssertionError

## 測試失敗訊息

```
junit.framework.AssertionFailedError: expected:<161> but was:<162>
	at android.display.cts.DisplayTest.testGetDisplayAttrs(DisplayTest.java:XXX)
```

## 相關日誌

```
02-20 10:35:20.456 D/DisplayManagerService: Creating overlay display device: 181x161/214
02-20 10:35:20.458 D/OverlayDisplayAdapter: getDisplayDeviceInfoLocked: width=181, height=162
02-20 10:35:20.463 I/DisplayTest: Secondary display height: 162, expected: 161
```

## 問題描述

CTS 測試 `testGetDisplayAttrs` 驗證 overlay display 的屬性是否正確。測試預期次級顯示器高度為 161 像素，但實際回報的高度為 162 像素。

這表示在設置顯示器高度屬性時存在計算錯誤。

## 任務

1. 找出導致高度多出 1 像素的程式碼錯誤
2. 修復該錯誤，使 overlay display 正確回報高度
3. 確保修改不影響其他顯示器屬性
