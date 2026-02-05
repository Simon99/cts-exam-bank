# CTS 測試失敗 — HDR 亮度異常

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testDefaultDisplayHdrCapability`

## CTS 失敗 Log
```
junit.framework.AssertionError
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at org.junit.Assert.assertTrue(Assert.java:53)
  at android.display.cts.DisplayTest.testDefaultDisplayHdrCapability(DisplayTest.java:369)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
