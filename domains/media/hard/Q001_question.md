# CTS 測試失敗 — MediaCodec + MediaMuxer + MediaExtractor 完整流程錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaTestCases`
- Test: `android.media.cts.MuxerTest#testMuxerMp4`

## CTS 失敗 Log
```
junit.framework.AssertionError: Video re-muxed file validation failed
After encode -> mux -> extract cycle:
Expected frame count: 100
Actual extracted frames: 0
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.media.cts.MuxerTest.testMuxerMp4(MuxerTest.java:512)
Caused by: java.lang.IllegalStateException: No valid samples in track
  at android.media.MediaExtractor.readSampleData(MediaExtractor.java:567)
```

## 額外資訊
- 測試流程：Camera 預覽 → MediaCodec 編碼 → MediaMuxer 寫入 → MediaExtractor 驗證
- MediaMuxer.stop() 正常完成
- 但 MediaExtractor 打開輸出檔案後無法讀取任何 sample
- 檔案大小約 4KB（只有 header，無 video data）

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
需要追蹤資料從 encoder output 到 muxer 到最終檔案的完整流程。
