# CTS 測試失敗 — Encoder B-frame PTS 順序錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.VideoEncoderTest#testBFrameOutputTimestamp`

## CTS 失敗 Log
```
junit.framework.AssertionError: B-frame PTS ordering incorrect
Expected: monotonically increasing DTS with correct CTTS offset
Actual: DTS sequence [0, 66666, 33333, 100000, ...] is non-monotonic
  
Frame analysis:
  Frame 0: PTS=0, DTS=0, type=I (correct)
  Frame 1: PTS=66666, DTS=66666, type=P (expected DTS=33333)
  Frame 2: PTS=33333, DTS=33333, type=B (expected DTS=66666)
  
CTTS offset calculation failed: negative offset detected
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.VideoEncoderTest.validateBFrameTimestamp(VideoEncoderTest.java:845)
  at android.mediav2.cts.VideoEncoderTest.testBFrameOutputTimestamp(VideoEncoderTest.java:892)
```

## 額外資訊
- 測試編碼器配置：AVC encoder with B-frames enabled (maxBframes=1)
- GOP structure: I-B-P-B-P-B-...
- B-frame reordering 應該產生正確的 DTS（decode order）和 PTS（presentation order）
- 輸出的 MP4 檔案無法正確播放，因為 CTTS box 包含負值

## 背景知識
H.264 B-frame 編碼時：
- PTS (Presentation Time Stamp): 顯示順序時間戳
- DTS (Decode Time Stamp): 解碼順序時間戳
- CTTS offset = PTS - DTS（必須 >= 0）

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 B-frame timestamp reordering 的正確邏輯
3. 提出修復方案並驗證 CTS 通過

## 提示
需要追蹤 encoder 輸出 → MediaCodec → MPEG4Writer 的完整 timestamp 處理流程。
