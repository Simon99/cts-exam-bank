# CTS 測試失敗 — Multi-track Muxing 問題

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaTestCases`
- Test: `android.media.cts.MuxerTest#testMuxerMultiTrack`

## CTS 失敗 Log
```
junit.framework.AssertionError: Multi-track interleave order incorrect
Expected: audio and video samples interleaved by timestamp
Actual: all audio samples followed by all video samples
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.media.cts.MuxerTest.testMuxerMultiTrack(MuxerTest.java:723)

File analysis shows:
- Audio samples at offset 0-50000
- Video samples at offset 50001-200000
- No interleaving detected
```

## 額外資訊
- 測試同時 mux 2 個 audio track 和 1 個 video track
- 預期 samples 按 timestamp 交錯寫入
- 實際上所有 audio 寫完才寫 video
- 導致 seek 效能差

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
需要理解 MPEG4Writer 的 interleave 機制。
