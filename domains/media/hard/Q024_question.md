# CTS 測試失敗 — HDR Metadata 傳遞錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.EncoderHDRInfoTest#testHdr10PlusMetadata`

## CTS 失敗 Log
```
junit.framework.AssertionError: HDR10+ dynamic metadata lost in encode/decode cycle
Expected: HDR10+ metadata present in output frame
Actual: metadata is null
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertNotNull(Assert.java:712)
  at android.mediav2.cts.EncoderHDRInfoTest.testHdr10PlusMetadata(EncoderHDRInfoTest.java:189)

Input frame has KEY_HDR10_PLUS_INFO with 256 bytes
Output frame KEY_HDR10_PLUS_INFO returns null
```

## 額外資訊
- 測試 HDR10+ encode → decode 流程
- Input frame 包含有效的 HDR10+ dynamic metadata
- Encode 後 mux 到 MP4
- Decode 時 metadata 丟失

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 HDR metadata 從 input 到 bitstream 到 output 的傳遞路徑。
