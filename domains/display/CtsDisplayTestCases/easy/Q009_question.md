# CTS 測試失敗 — Display Flags 設定錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testFlags`

## CTS 失敗 Log
```
junit.framework.AssertionError: expected:<6> but was:<2>
  at org.junit.Assert.assertEquals(Assert.java:115)
  at org.junit.Assert.assertEquals(Assert.java:144)
  at android.display.cts.DisplayTest.testFlags(DisplayTest.java:...)
```

## 補充信息
測試驗證 overlay display 的 flags 應包含 `FLAG_PRESENTATION | FLAG_TRUSTED`（值為 6），但實際只有 `FLAG_TRUSTED`（值為 2）。

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
