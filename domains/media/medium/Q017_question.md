# CTS 測試失敗 — MediaFormat CSD Buffer 處理錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderTest#testDecodeWithCSD`

## CTS 失敗 Log
```
junit.framework.AssertionError: CSD buffer corrupted after MediaFormat roundtrip
Expected csd-0 size: 24
Actual csd-0 size: 0
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.CodecDecoderTest.testDecodeWithCSD(CodecDecoderTest.java:512)
```

## 額外資訊
- 測試設定 H.264 decoder 的 csd-0 (SPS) 和 csd-1 (PPS)
- 從 MediaFormat 取回時 csd-0 是空的
- getByteBuffer("csd-0") 返回 null 或 empty buffer

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 MediaFormat 中 ByteBuffer 類型的 key 的存取路徑。
