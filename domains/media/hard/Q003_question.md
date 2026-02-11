# CTS 測試失敗 — Adaptive Playback 解析度切換問題

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.AdaptivePlaybackTest#testResolutionChange`

## CTS 失敗 Log
```
junit.framework.AssertionError: Output buffer corrupted after resolution change
Frame 51 (first frame after resolution change):
Expected: valid decoded frame 1920x1080
Actual: buffer contains garbage data
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.AdaptivePlaybackTest.testResolutionChange(AdaptivePlaybackTest.java:234)

Native crash log:
A/DEBUG: signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x7f8d000000
A/DEBUG: #0 pc 000456a8 /system/lib64/libstagefright.so (CCodecBufferChannel::renderOutputBuffer+456)
```

## 額外資訊
- 測試從 1280x720 切換到 1920x1080
- 切換前的 frame decode 正常
- 切換後第一個 frame 解碼失敗
- 偶爾出現 native crash

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
需要理解 MediaCodec 的 adaptive playback 機制和 buffer 管理。
