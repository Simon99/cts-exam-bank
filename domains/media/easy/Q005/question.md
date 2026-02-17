# CTS 測試失敗 — MediaMuxer 輸出格式錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.MuxerTest#testMuxerMp4`

## CTS 失敗 Log
```
java.lang.IllegalStateException: Failed to open muxer: expected MP4 container but got WebM header
  at android.media.MediaMuxer.nativeSetup(Native Method)
  at android.media.MediaMuxer.<init>(MediaMuxer.java:252)
  at android.mediav2.cts.MuxerTest.testMuxerMp4(MuxerTest.java:312)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
