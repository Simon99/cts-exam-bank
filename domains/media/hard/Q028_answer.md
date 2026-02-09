# Media-H-Q028 解答

## Root Cause
問題出在三個檔案的 B-frame timestamp 處理：

1. `MPEG4Writer.cpp` - CTTS offset 計算錯誤：
```cpp
// Bug: 使用錯誤的 offset 基準導致負值
cttsOffsetTimeUs = timestampUs - decodingTimeUs;  // 可能為負
// 正確應該是: timestampUs + kMaxCttsOffsetTimeUs - decodingTimeUs
```

2. `C2SoftAvcEnc.cpp` - B-frame DTS 設置問題：
```cpp
// Bug: 沒有正確設置 decodingTime metadata
// 導致下游使用錯誤的 DTS
```

3. `MediaCodec.java` - BufferInfo timestamp 傳遞問題：
```java
// Bug: presentationTimeUs 和 decodingTimeUs 混淆
// 導致 muxer 收到錯誤的時間戳
```

## B-frame Timestamp 原理

正確的 I-B-P 序列 (30fps):
```
Display order: I(0) B(1) P(2) B(3) P(4)
Decode order:  I(0) P(2) B(1) P(4) B(3)

PTS (display): 0, 33333, 66666, 100000, 133333 us
DTS (decode):  0, 33333, 66666, 100000, 133333 us (reordered)
CTTS offset:   0, 33333, 0,     33333,  0      us
```

## 涉及檔案
- `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
- `frameworks/av/media/codec2/components/avc/C2SoftAvcEnc.cpp`
- `frameworks/base/media/java/android/media/MediaCodec.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案，從 encoder 到 muxer 的完整流程

## 追蹤路徑
1. CTS log → CTTS offset 為負值
2. 檢查 MPEG4Writer → 發現 cttsOffsetTimeUs 計算錯誤
3. 追蹤 decodingTimeUs 來源 → MediaCodecSource
4. 追蹤 encoder output → C2SoftAvcEnc 的 timestamp 設置
5. 追蹤 Java 層 → BufferInfo 傳遞問題

## 正確的 CTTS 計算

```cpp
// MPEG4Writer.cpp line ~3839
// 使用固定 offset 確保非負：
cttsOffsetTimeUs = timestampUs + kMaxCttsOffsetTimeUs - decodingTimeUs;
// kMaxCttsOffsetTimeUs = 30 minutes (足夠大的正值)
```

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 理解 B-frame PTS/DTS 概念 | 20% | 能解釋 reordering 原理 |
| 正確定位所有相關檔案 | 25% | 找到全部 3 個檔案 |
| 理解 CTTS offset 計算 | 25% | 知道為什麼需要正值 |
| 修復方案正確 | 20% | 恢復正確的 offset 計算 |
| 驗證修復完整 | 10% | 確保所有 frame type 都正確 |

## 常見錯誤方向
- 只看 encoder 不追蹤 muxer
- 忽略 kMaxCttsOffsetTimeUs 的作用
- 混淆 PTS 和 DTS 的定義
- 認為問題在 MediaExtractor（其實是 writer 問題）
