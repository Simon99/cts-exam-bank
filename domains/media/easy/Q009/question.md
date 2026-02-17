# CTS 測試失敗 — MediaFormat Duration 單位錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.ExtractorTest#testMediaFormatDuration`

## CTS 失敗 Log
```
junit.framework.AssertionError: Duration mismatch
Expected: 10000000 (10 seconds in microseconds)
Actual: 10000 (10 seconds in milliseconds)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.ExtractorTest.testMediaFormatDuration(ExtractorTest.java:234)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
