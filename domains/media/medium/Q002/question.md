# CTS 測試失敗 — MediaExtractor Track Selection 問題

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.ExtractorTest#testTrackSelection`

## CTS 失敗 Log
```
junit.framework.AssertionError: Track format mismatch after selection
Selected track: 0 (video/avc)
But getTrackFormat returned format for track: 1 (audio/mp4a-latm)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.ExtractorTest.testTrackSelection(ExtractorTest.java:289)
```

## 額外資訊
- 測試文件包含 2 個 track：video (track 0) 和 audio (track 1)
- 調用 `selectTrack(0)` 後，`getTrackFormat(0)` 返回的是 audio 格式

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
