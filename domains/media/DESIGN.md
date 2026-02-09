# CTS Media 領域題庫設計

## 版本
- **版本號**: v1.0.0
- **創建時間**: 2025-02-10
- **更新時間**: 2025-02-10

## 概覽
共 30 題：Easy 10 題、Medium 10 題、Hard 10 題

## 難度定義
- **Easy**: 讀 CTS fail log 就能定位，單一檔案修改
- **Medium**: 需要加額外 log 追蹤，1-2 個檔案
- **Hard**: 需要理解多個檔案交互，≥3 個檔案

## 涵蓋的 CTS 測試模組
- `CtsMediaV2TestCases` - MediaCodec, MediaExtractor, MediaMuxer 相關
- `CtsMediaTestCases` - 傳統 media API 測試

## 涵蓋的 Framework 源碼
- `frameworks/base/media/java/android/media/` - Java 層 Media API
- `frameworks/av/media/` - Native 層 Media 實現
  - libstagefright - 媒體框架核心
  - libmedia - 媒體客戶端庫
  - codec2 - Codec 2.0 框架

---

## Easy 題目 (10 題)

### Q001 - MediaFormat KEY_WIDTH/KEY_HEIGHT 交換
- **測試**: `MediaFormatUnitTest`
- **Bug**: 在 MediaFormat.java 中交換 width 和 height 的 getter
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaFormat.java`

### Q002 - MediaCodecInfo isEncoder() 返回值取反
- **測試**: `CodecInfoTest`
- **Bug**: isEncoder() 返回 !isEncoder
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaCodecInfo.java`

### Q003 - MediaExtractor getSampleTime() 返回負值
- **測試**: `ExtractorTest`
- **Bug**: getSampleTime() 返回 -presentationTimeUs
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaExtractor.java`

### Q004 - MediaFormat KEY_SAMPLE_RATE 返回錯誤值
- **測試**: `AudioEncoderTest`
- **Bug**: getSampleRate 時返回錯誤的值 (除以 2)
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaFormat.java`

### Q005 - MediaMuxer OutputFormat 常量錯誤
- **測試**: `MuxerTest`
- **Bug**: MUXER_OUTPUT_MPEG_4 和 MUXER_OUTPUT_WEBM 值交換
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaMuxer.java`

### Q006 - MediaCodecInfo isSoftwareOnly() 邏輯錯誤
- **測試**: `CodecInfoTest`
- **Bug**: isSoftwareOnly() 用錯誤的 flag 判斷
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaCodecInfo.java`

### Q007 - MediaFormat KEY_CHANNEL_COUNT 取值錯誤
- **測試**: `AudioEncoderTest`
- **Bug**: getInteger(KEY_CHANNEL_COUNT) 返回 0
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaFormat.java`

### Q008 - MediaExtractor getTrackCount() 返回 0
- **測試**: `ExtractorTest`
- **Bug**: getTrackCount() 固定返回 0
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaExtractor.java`

### Q009 - MediaFormat KEY_DURATION 單位錯誤
- **測試**: `ExtractorTest`
- **Bug**: duration 從微秒變成毫秒 (除以 1000)
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaFormat.java`

### Q010 - MediaCodecInfo isHardwareAccelerated() 與 isSoftwareOnly() 邏輯衝突
- **測試**: `CodecInfoTest`
- **Bug**: isHardwareAccelerated() 返回與 isSoftwareOnly() 相同結果
- **涉及檔案**: `frameworks/base/media/java/android/media/MediaCodecInfo.java`

---

## Medium 題目 (10 題)

### Q011 - MediaCodec configure() color format 處理錯誤
- **測試**: `CodecDecoderTest`
- **Bug**: COLOR_FormatYUV420Flexible 映射到錯誤格式
- **涉及檔案**: 
  - `frameworks/base/media/java/android/media/MediaCodec.java`
  - `frameworks/base/media/java/android/media/MediaCodecInfo.java`

### Q012 - MediaExtractor + MediaFormat track selection 問題
- **測試**: `ExtractorTest`
- **Bug**: selectTrack() 後 getTrackFormat() 返回錯誤 track
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaExtractor.java`
  - `frameworks/av/media/libstagefright/MediaExtractorFactory.cpp`

### Q013 - AudioFormat PCM encoding 不一致
- **測試**: `AudioEncoderTest`
- **Bug**: ENCODING_PCM_16BIT 和 ENCODING_PCM_FLOAT 處理不一致
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/AudioFormat.java`
  - `frameworks/base/media/java/android/media/MediaFormat.java`

### Q014 - MediaMuxer writeSampleData timestamp 處理錯誤
- **測試**: `MuxerTest`
- **Bug**: presentationTimeUs 被錯誤修改
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaMuxer.java`
  - `frameworks/av/media/libstagefright/MediaMuxer.cpp`

### Q015 - MediaCodec BufferInfo flags 設置錯誤
- **測試**: `CodecDecoderTest`
- **Bug**: BUFFER_FLAG_END_OF_STREAM 處理不當
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaCodec.java`
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`

### Q016 - MediaCodecList 過濾邏輯錯誤
- **測試**: `CodecListTest`
- **Bug**: REGULAR_CODECS 和 ALL_CODECS 過濾邏輯錯誤
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaCodecList.java`
  - `frameworks/base/media/java/android/media/MediaCodecInfo.java`

### Q017 - MediaFormat CSD (Codec Specific Data) 處理錯誤
- **測試**: `CodecDecoderTest`
- **Bug**: csd-0, csd-1 buffer 處理錯誤
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaFormat.java`
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`

### Q018 - MediaExtractor seekTo 模式錯誤
- **測試**: `ExtractorTest`
- **Bug**: SEEK_TO_PREVIOUS_SYNC 行為與文檔不符
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaExtractor.java`
  - `frameworks/av/media/libstagefright/NuMediaExtractor.cpp`

### Q019 - MediaCodec output format 更新不正確
- **測試**: `CodecDecoderTest`
- **Bug**: getOutputFormat() 在 format change 後返回舊值
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaCodec.java`
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`

### Q020 - MediaCodecInfo profile level 驗證錯誤
- **測試**: `CodecInfoTest`
- **Bug**: profileLevels array 處理錯誤
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaCodecInfo.java`
  - `frameworks/av/media/libstagefright/MediaCodecList.cpp`

---

## Hard 題目 (10 題)

### Q021 - MediaCodec + MediaMuxer + MediaExtractor 完整流程錯誤
- **測試**: `MuxerTest#testMuxerMp4`
- **Bug**: 編碼後 mux 再 extract 驗證失敗
- **涉及檔案**:
  - `frameworks/base/media/java/android/media/MediaCodec.java`
  - `frameworks/base/media/java/android/media/MediaMuxer.java`
  - `frameworks/base/media/java/android/media/MediaExtractor.java`

### Q022 - Audio/Video 同步問題
- **測試**: `MuxerTest`
- **Bug**: A/V pts 計算錯誤導致不同步
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
  - `frameworks/av/media/libstagefright/MediaMuxer.cpp`
  - `frameworks/base/media/java/android/media/MediaMuxer.java`

### Q023 - Adaptive Playback 解析度切換問題
- **測試**: `AdaptivePlaybackTest`
- **Bug**: resolution change 時 buffer 處理錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`
  - `frameworks/av/media/codec2/sfplugin/CCodecBufferChannel.cpp`
  - `frameworks/base/media/java/android/media/MediaCodec.java`

### Q024 - HDR metadata 傳遞錯誤
- **測試**: `EncoderHDRInfoTest`
- **Bug**: HDR10+ metadata 在 encode/decode 流程中丟失
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`
  - `frameworks/av/media/libstagefright/HevcUtils.cpp`
  - `frameworks/base/media/java/android/media/MediaFormat.java`

### Q025 - Surface decode 輸出問題
- **測試**: `CodecDecoderSurfaceTest`
- **Bug**: Surface 渲染 timestamp 錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`
  - `frameworks/av/media/codec2/sfplugin/CCodecBufferChannel.cpp`
  - `frameworks/native/libs/gui/Surface.cpp`

### Q026 - Multi-track muxing 問題
- **測試**: `MuxerTest#testMuxerMultiTrack`
- **Bug**: 多 track interleave 順序錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
  - `frameworks/av/media/libstagefright/MediaMuxer.cpp`
  - `frameworks/base/media/java/android/media/MediaMuxer.java`

### Q027 - Decoder color aspects 處理錯誤
- **測試**: `DecoderColorAspectsTest`
- **Bug**: color primaries/transfer/matrix 映射錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`
  - `frameworks/av/media/libstagefright/ColorConverter.cpp`
  - `frameworks/av/media/libstagefright/include/media/stagefright/ColorConverter.h`

### Q028 - Encoder B-frame 處理問題
- **測試**: `VideoEncoderTest`
- **Bug**: B-frame PTS 順序錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
  - `frameworks/av/media/codec2/components/avc/C2SoftAvcEnc.cpp`
  - `frameworks/base/media/java/android/media/MediaCodec.java`

### Q029 - MediaCodec async callback 問題
- **測試**: `CodecDecoderTest`
- **Bug**: callback 模式下 output buffer 狀態錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/MediaCodec.cpp`
  - `frameworks/base/media/java/android/media/MediaCodec.java`
  - `frameworks/av/media/libstagefright/ACodec.cpp`

### Q030 - MediaExtractor + DRM 處理問題
- **測試**: `ExtractorTest`
- **Bug**: 加密 track 的 sample 處理錯誤
- **涉及檔案**:
  - `frameworks/av/media/libstagefright/NuMediaExtractor.cpp`
  - `frameworks/av/drm/libmediadrm/DrmHal.cpp`
  - `frameworks/base/media/java/android/media/MediaExtractor.java`

---

## 注意事項
1. 所有 patch 需要確保 boot safe (不會導致無法開機)
2. Bug 需要設計成 CTS 會失敗但系統可正常運行
3. 優先使用 Java 層修改以降低風險

## 更新時間
v1.0.0 - 2025-02-10 - 初始設計
