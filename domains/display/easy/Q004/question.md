# Question DIS-E004

## CTS 測試資訊
- **Module**: CtsDisplayTestCases
- **Test**: android.display.cts.DisplayTest#testMode
- **失敗類型**: AssertionError

## 測試失敗訊息

```
junit.framework.AssertionFailedError: expected:<1> but was:<-1>
	at android.display.cts.DisplayTest.testMode(DisplayTest.java:XXX)
```

## 相關日誌

```
02-20 10:45:45.123 D/DisplayManagerService: Creating overlay display device: 181x161/214
02-20 10:45:45.125 D/OverlayDisplayAdapter: getDisplayDeviceInfoLocked: defaultModeId=-1
02-20 10:45:45.130 I/DisplayTest: Default mode ID: -1, expected first supported mode
02-20 10:45:45.132 W/DisplayTest: Display.getMode() returned mode with invalid ID
```

## 問題描述

CTS 測試 `testMode` 驗證 overlay display 的顯示模式設定是否正確。測試預期預設模式 ID 應該是第一個支援的模式，但實際回報的 defaultModeId 為 -1（無效值）。

這表示在設置 defaultModeId 時使用了錯誤的值。

## 任務

1. 找出導致 defaultModeId 被設為 -1 的程式碼錯誤
2. 修復該錯誤，使 defaultModeId 正確設為第一個支援的模式
3. 確認修改符合 Display.Mode 的設計規範
