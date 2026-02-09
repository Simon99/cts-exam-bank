# CTS 測試失敗 — MediaExtractor seekTo 模式錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaTestCases`
- Test: `android.media.cts.ExtractorTest#testSeekToPreviousSync`

## CTS 失敗 Log
```
junit.framework.AssertionError: SEEK_TO_PREVIOUS_SYNC did not seek to correct position
Expected sample time: 1000000 (previous keyframe at 1s)
Actual sample time: 2000000 (seeked forward to next keyframe)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.media.cts.ExtractorTest.testSeekToPreviousSync(ExtractorTest.java:287)
```

## 額外資訊
- 測試呼叫 `seekTo(1500000, SEEK_TO_PREVIOUS_SYNC)`
- 預期 seek 到 1.0 秒 (前一個 keyframe)
- 實際 seek 到 2.0 秒 (後一個 keyframe)
- 行為像是 SEEK_TO_NEXT_SYNC

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 seekTo 的 mode 參數從 Java 層到 native 層的傳遞。
