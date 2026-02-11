# CTS 測試失敗 — MediaMuxer Timestamp 處理錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.MuxerTest#testMuxerTimestamp`

## CTS 失敗 Log
```
junit.framework.AssertionError: Sample timestamp verification failed
Input PTS: 33333, 66666, 100000, ...
Output PTS: 33333, 33333, 33333, ... (all same!)
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.MuxerTest.verifyTimestamps(MuxerTest.java:456)
```

## 額外資訊
- 寫入 muxer 時 presentationTimeUs 遞增
- 但 extract 後所有 sample 的 PTS 都相同

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
