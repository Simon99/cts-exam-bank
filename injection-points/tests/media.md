# Media 模組注入點分布列表

**CTS 路徑**: `cts/tests/media/`  
**更新時間**: 2026-02-11  
**版本**: v1.0.0

---

## 概覽

- **總注入點數**: 52
- **按難度分布**: Easy(18) / Medium(22) / Hard(12)
- **涵蓋測試類別**: 
  - CodecDecoderTest, CodecEncoderTest, CodecUnitTest
  - ExtractorTest, ExtractorUnitTest
  - MuxerTest, MuxerUnitTest
  - AudioEncoderTest, VideoEncoderTest
  - DecoderColorAspectsTest, EncoderColorAspectsTest
  - AdaptivePlaybackTest

---

## 對應 AOSP 源碼路徑

### Native 層 (C++)
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/av/media/libstagefright/MediaMuxer.cpp`
- `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
- `frameworks/av/media/libstagefright/NuMediaExtractor.cpp`
- `frameworks/av/media/libstagefright/Utils.cpp`
- `frameworks/av/media/codec2/components/avc/C2SoftAvcDec.cpp`
- `frameworks/av/media/codec2/components/avc/C2SoftAvcEnc.cpp`
- `frameworks/av/media/codec2/components/hevc/C2SoftHevcDec.cpp`
- `frameworks/av/media/module/extractors/mp4/MPEG4Extractor.cpp`

### Java 層
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/base/media/java/android/media/MediaExtractor.java`
- `frameworks/base/media/java/android/media/MediaMuxer.java`
- `frameworks/base/media/java/android/media/MediaFormat.java`

---

## 注入點清單

### 1. MediaCodec 狀態管理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-001 | MediaCodec.cpp | configure() | 2413-2500 | STATE, COND | Medium | CodecUnitTest |
| MED-002 | MediaCodec.cpp | start() | 3050-3120 | STATE, ERR | Easy | CodecDecoderTest |
| MED-003 | MediaCodec.cpp | stop() | 3118-3130 | STATE | Easy | CodecDecoderTest |
| MED-004 | MediaCodec.cpp | flush() | ~3150 | STATE, SYNC | Medium | CodecDecoderTest |
| MED-005 | MediaCodec.cpp | release() | 3153-3165 | RES, STATE | Easy | CodecUnitTest |
| MED-006 | MediaCodec.cpp | reset() | 3167-3200 | STATE, RES | Medium | CodecUnitTest |
| MED-007 | MediaCodec.cpp | mState 狀態檢查 | ~1278 | COND, STATE | Easy | CodecUnitTest |

### 2. Buffer 管理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-008 | MediaCodec.cpp | queueInputBuffer() | 3200-3250 | BOUND, RES | Medium | CodecDecoderTest |
| MED-009 | MediaCodec.cpp | queueInputBuffers() | 3250-3320 | BOUND, COND | Hard | CodecDecoderMultiAccessUnitTest |
| MED-010 | MediaCodec.cpp | dequeueInputBuffer() | ~3400 | SYNC, BOUND | Medium | CodecEncoderTest |
| MED-011 | MediaCodec.cpp | dequeueOutputBuffer() | ~3500 | SYNC, BOUND | Medium | CodecDecoderTest |
| MED-012 | MediaCodec.cpp | releaseOutputBuffer() | ~3600 | RES, STATE | Easy | CodecDecoderSurfaceTest |
| MED-013 | MediaCodec.cpp | hasPendingBuffer() | 3125-3135 | COND | Easy | CodecDecoderPauseTest |

### 3. 格式處理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-014 | MediaCodec.cpp | updateLowLatency() | ~2400 | COND | Easy | CodecInfoTest |
| MED-015 | MediaCodec.cpp | createMediaMetrics() | ~2350-2400 | CALC | Medium | CodecInfoTest |
| MED-016 | MediaCodec.cpp | connectFormatShaper() | ~2500-2600 | COND, ERR | Hard | VideoEncoderTest |
| MED-017 | Utils.cpp | convertMessageToMetaData() | 全檔案 | STR, CALC | Medium | MediaFormatUnitTest |

### 4. MediaMuxer

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-018 | MediaMuxer.cpp | create() | 46-70 | COND, ERR | Medium | MuxerUnitTest |
| MED-019 | MediaMuxer.cpp | addTrack() | 97-140 | STATE, BOUND | Medium | MuxerTest |
| MED-020 | MediaMuxer.cpp | setOrientationHint() | 142-155 | COND, BOUND | Easy | MuxerTest |
| MED-021 | MediaMuxer.cpp | setLocation() | 157-170 | COND, CALC | Medium | MuxerTest |
| MED-022 | MediaMuxer.cpp | start() | 173-182 | STATE | Easy | MuxerTest |
| MED-023 | MediaMuxer.cpp | stop() | 184-200 | STATE, RES | Easy | MuxerTest |
| MED-024 | MediaMuxer.cpp | writeSampleData() | ~210-280 | BOUND, STATE | Medium | MuxerTest |
| MED-025 | MediaMuxer.cpp | isMp4Format() | 41-45 | COND | Easy | MuxerUnitTest |

### 5. MPEG4Writer

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-026 | MPEG4Writer.cpp | Track::isValid() | ~110-130 | COND, BOUND | Medium | MuxerTest |
| MED-027 | MPEG4Writer.cpp | Track 狀態變數 | 320-380 | STATE | Hard | MuxerTest |
| MED-028 | MPEG4Writer.cpp | ListTableEntries::add() | ~240-300 | BOUND, CALC | Hard | MuxerTest |
| MED-029 | MPEG4Writer.cpp | mMaxCttsOffsetTimeUs 常數 | 65 | CALC, BOUND | Medium | MuxerTest |
| MED-030 | MPEG4Writer.cpp | kMaxMetadataSize 常數 | 64 | BOUND | Easy | MuxerTest |

### 6. NuMediaExtractor

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-031 | NuMediaExtractor.cpp | initMediaExtractor() | 68-95 | ERR, STATE | Medium | ExtractorTest |
| MED-032 | NuMediaExtractor.cpp | setDataSource() (path) | 97-115 | ERR | Easy | ExtractorTest |
| MED-033 | NuMediaExtractor.cpp | setDataSource() (fd) | 117-140 | BOUND, ERR | Medium | ExtractorUnitTest |
| MED-034 | NuMediaExtractor.cpp | selectTrack() | ~200 | BOUND, STATE | Easy | ExtractorTest |
| MED-035 | NuMediaExtractor.cpp | unselectTrack() | ~220 | BOUND, STATE | Easy | ExtractorTest |
| MED-036 | NuMediaExtractor.cpp | readSampleData() | ~300 | BOUND, RES | Medium | ExtractorTest |

### 7. Codec2 組件 (Software Codecs)

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-037 | C2SoftAvcDec.cpp | IntfImpl 參數設定 | 45-150 | BOUND, CALC | Hard | CodecDecoderTest |
| MED-038 | C2SoftAvcDec.cpp | kMinInputBufferSize 常數 | 30 | BOUND | Easy | CodecDecoderTest |
| MED-039 | C2SoftAvcDec.cpp | kMaxOutputDelay 常數 | 35-37 | CALC | Medium | CodecDecoderTest |
| MED-040 | C2SoftAvcDec.cpp | SizeSetter() | ~80 | BOUND, COND | Medium | CodecDecoderTest |
| MED-041 | C2SoftAvcDec.cpp | ProfileLevelSetter() | ~100-115 | COND | Medium | EncoderProfileLevelTest |
| MED-042 | C2SoftAvcEnc.cpp | 編碼器參數設定 | 全檔案 | BOUND, CALC | Hard | VideoEncoderTest |

### 8. 顏色處理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-043 | MediaCodec.cpp | HDR 相關常數 | 160-175 | STR | Easy | DecoderColorAspectsTest |
| MED-044 | C2SoftAvcDec.cpp | ColorInfo 設定 | ~125-145 | CALC, COND | Hard | DecoderColorAspectsTest |
| MED-045 | C2SoftAvcDec.cpp | ColorAspects 設定 | ~135-140 | CALC | Medium | EncoderColorAspectsTest |

### 9. 錯誤處理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-046 | MediaCodec.cpp | isResourceError() | ~2475 | COND, ERR | Easy | CodecUnitTest |
| MED-047 | MediaCodec.cpp | configure() 重試邏輯 | 2478-2495 | ERR, STATE | Hard | CodecUnitTest |
| MED-048 | MediaMuxer.cpp | addTrack() 錯誤回傳 | 126-127 | ERR | Easy | MuxerUnitTest |
| MED-049 | NuMediaExtractor.cpp | initMediaExtractor() 錯誤處理 | 75-90 | ERR | Medium | ExtractorTest |

### 10. 資源管理

| ID | AOSP 檔案 | 函數/區塊 | 行號 | 注入類型 | 難度 | 對應 CTS Test |
|----|-----------|----------|------|----------|------|---------------|
| MED-050 | MediaCodec.cpp | ResourceManagerServiceProxy | 400-600 | RES, SYNC | Hard | CodecUnitTest |
| MED-051 | MediaCodec.cpp | reclaimResource() | ~420 | RES, STATE | Hard | CodecUnitTest |
| MED-052 | NuMediaExtractor.cpp | ~NuMediaExtractor() 析構函數 | 53-65 | RES | Medium | ExtractorTest |

---

## 難度分布統計

| 難度 | 數量 | 占比 |
|------|------|------|
| Easy | 18 | 34.6% |
| Medium | 22 | 42.3% |
| Hard | 12 | 23.1% |
| **總計** | **52** | **100%** |

---

## 注入類型分布統計

| 類型 | 說明 | 數量 |
|------|------|------|
| COND | 條件判斷 | 22 |
| STATE | 狀態轉換 | 20 |
| BOUND | 邊界檢查 | 18 |
| ERR | 錯誤處理 | 14 |
| RES | 資源管理 | 12 |
| CALC | 數值計算 | 12 |
| SYNC | 同步問題 | 4 |
| STR | 字串處理 | 3 |

> 注意：單一注入點可能有多個類型

---

## 推薦優先順序

### 高優先級（CTS 覆蓋度高）
1. **MED-001 ~ MED-007**: MediaCodec 狀態管理 — 最基礎的 API，幾乎所有 CTS 都會用到
2. **MED-018 ~ MED-025**: MediaMuxer — MuxerTest 專門測試
3. **MED-031 ~ MED-036**: Extractor — ExtractorTest 專門測試

### 中優先級（進階功能）
4. **MED-008 ~ MED-013**: Buffer 管理 — 需要理解異步處理
5. **MED-037 ~ MED-042**: Codec2 組件 — 需要理解 codec 參數

### 低優先級（特殊場景）
6. **MED-050 ~ MED-052**: 資源管理 — 跨進程、複雜度高
7. **MED-043 ~ MED-045**: 顏色處理 — 特定場景

---

## 使用方式

1. **選擇注入點**: 根據難度需求和 CTS 覆蓋度選擇
2. **查看源碼**: 到對應行號確認程式碼結構
3. **設計 Bug**: 根據注入類型設計合理的 bug
4. **產生 Patch**: 確保 patch 能 apply 到 aosp-sandbox-1
5. **驗證**: 執行對應的 CTS 測試確認 bug 能被檢測

---

**文件位置**: `~/develop_claw/cts-exam-bank/injection-points/tests/media.md`
