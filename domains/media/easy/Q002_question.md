# CTS 測試失敗 — MediaCodecInfo isEncoder 判斷錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecInfoTest#testCodecType`

## CTS 失敗 Log
```
junit.framework.AssertionError: Codec type mismatch for codec: c2.android.avc.decoder
Expected isEncoder(): false, Actual: true
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertFalse(Assert.java:65)
  at android.mediav2.cts.CodecInfoTest.testCodecType(CodecInfoTest.java:156)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
