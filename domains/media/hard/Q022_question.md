# CTS 測試失敗 — Audio/Video 同步問題

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaTestCases`
- Test: `android.media.cts.MuxerTest#testAVSync`

## CTS 失敗 Log
```
junit.framework.AssertionError: A/V sync drift exceeds tolerance
Expected max drift: 33ms (1 frame @ 30fps)
Actual drift: 500ms (audio ahead of video)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.media.cts.MuxerTest.testAVSync(MuxerTest.java:678)

Audio track PTS: 0, 21333, 42666, 64000, 85333...
Video track PTS: 500000, 533333, 566666, 600000...
```

## 額外資訊
- 測試同時 mux audio 和 video track
- Audio 以正確的 PTS 開始（從 0 開始）
- Video PTS 被偏移了 500ms
- 問題出現在 writeSampleData 的 timestamp 處理

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 presentationTimeUs 從 writeSampleData 到實際寫入檔案的過程。
