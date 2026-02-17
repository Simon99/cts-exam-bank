# CTS 測試失敗 — MediaCodec Output Format 更新不正確

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testFormatChange`

## CTS 失敗 Log
```
junit.framework.AssertionError: Output format not updated after INFO_OUTPUT_FORMAT_CHANGED
Expected width: 1920 (new format)
Actual width: 1280 (old format)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.CodecDecoderTest.testFormatChange(CodecDecoderTest.java:634)
```

## 額外資訊
- Decoder 收到 `INFO_OUTPUT_FORMAT_CHANGED` 後呼叫 `getOutputFormat()`
- 解析度從 1280x720 變成 1920x1080
- 但 `getOutputFormat()` 仍然返回舊的 1280x720

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 format change 事件從 native 到 Java 的更新路徑。
