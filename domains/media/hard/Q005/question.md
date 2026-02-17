# CTS 測試失敗 — Surface Decode 輸出問題

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecDecoderSurfaceTest#testDecodeToSurface`

## CTS 失敗 Log
```
junit.framework.AssertionError: Surface frame timestamp mismatch
Expected render timestamp: 1000000000 ns (1s)
Actual render timestamp: 0 ns
Frame rendered but with wrong timestamp
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.CodecDecoderSurfaceTest.testDecodeToSurface(CodecDecoderSurfaceTest.java:312)

SurfaceTexture.onFrameAvailable() timestamp = 0
Expected: presentationTimeUs * 1000 = 1000000000
```

## 額外資訊
- Decode 到 Surface 時 frame 正常顯示
- 但 SurfaceTexture 收到的 timestamp 永遠是 0
- 使用 releaseOutputBuffer(index, renderTimestampNs) 傳遞 timestamp

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 timestamp 從 MediaCodec 到 Surface 到 SurfaceTexture 的傳遞。
