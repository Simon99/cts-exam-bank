# CTS 測試失敗 — Display State 回報錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testDefaultDisplay`

## CTS 失敗 Log
```
junit.framework.AssertionError: expected:<0> but was:<-1>
  at org.junit.Assert.assertEquals(Assert.java:115)
  at org.junit.Assert.assertEquals(Assert.java:144)
  at android.display.cts.DisplayTest.testDefaultDisplay(DisplayTest.java:...)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
