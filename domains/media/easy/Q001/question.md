# CTS 測試失敗 — MediaFormat 寬高獲取異常

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testSimpleDecode`

## CTS 失敗 Log
```
junit.framework.AssertionError: Video dimensions mismatch
Expected width: 1920, Actual: 1080
Expected height: 1080, Actual: 1920
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.CodecDecoderTest.validateOutputFormat(CodecDecoderTest.java:245)
  at android.mediav2.cts.CodecDecoderTest.testSimpleDecode(CodecDecoderTest.java:312)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
