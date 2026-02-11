# CTS 測試失敗 — MediaCodec Color Format 映射錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testDecodeToYuv`

## CTS 失敗 Log
```
junit.framework.AssertionError: Unexpected color format in output
Expected: COLOR_FormatYUV420Flexible (0x7f420888)
Actual: COLOR_FormatYUV420Planar (0x13)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.CodecDecoderTest.testDecodeToYuv(CodecDecoderTest.java:378)
```

## 額外資訊
- 測試使用 `MediaCodec.configure()` 時指定 `COLOR_FormatYUV420Flexible`
- 但 decoder output format 顯示 `COLOR_FormatYUV420Planar`

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
可能需要追蹤 color format 從 configure 到 output format 的傳遞路徑。
