# CTS 測試失敗 — MediaExtractor getTrackCount 返回 0

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.ExtractorTest#testExtract`

## CTS 失敗 Log
```
junit.framework.AssertionError: No tracks found in media file
Expected: > 0, Actual: 0
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.mediav2.cts.ExtractorTest.testExtract(ExtractorTest.java:156)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
