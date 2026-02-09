# CTS 測試失敗 — Active Mode 不在 Supported Modes 中

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay`

## CTS 失敗 Log
```
java.lang.AssertionError
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.display.cts.DisplayTest.testActiveModeIsSupportedModesOnDefaultDisplay(DisplayTest.java:...)
```

## 補充信息
測試驗證 `Display.getMode()` 返回的當前模式必須在 `getSupportedModes()` 列表中，但實際未找到匹配。

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
