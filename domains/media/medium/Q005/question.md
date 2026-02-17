# CTS 測試失敗 — MediaCodec BufferInfo Flags 處理錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testDecodeEOS`

## CTS 失敗 Log
```
junit.framework.AssertionError: End of stream not detected
Expected BUFFER_FLAG_END_OF_STREAM in last output buffer
But got flags: 0
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.mediav2.cts.CodecDecoderTest.testDecodeEOS(CodecDecoderTest.java:523)
```

## 額外資訊
- Decoder 正常解碼所有 frames
- 但最後一個 output buffer 沒有 EOS flag

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
