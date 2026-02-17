# Media-H-Q025 解答

## Root Cause
問題涉及三個檔案的 timestamp 傳遞：

1. `MediaCodec.cpp` - releaseOutputBuffer 沒有傳遞 timestamp：
```cpp
// 呼叫 Surface::queueBuffer 時
// Bug: 沒有設定 timestamp
sp<Fence> fence;
// nativeWindow->queueBuffer(nativeWindow, buffer, fence);
// 缺少 nativeWindowSetBufferTimestamp()
```

2. `CCodecBufferChannel.cpp` - render timestamp 被忽略：
```cpp
// 在 renderOutputBuffer 中
// Bug: timestampNs 沒有傳給 Surface
```

3. `Surface.cpp` - buffer queue 時 timestamp 處理問題。

## 涉及檔案
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/av/media/codec2/sfplugin/CCodecBufferChannel.cpp`
- `frameworks/native/libs/gui/Surface.cpp`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → SurfaceTexture timestamp 是 0
2. 追蹤 `SurfaceTexture.getTimestamp()` → 發現 buffer 沒帶 timestamp
3. 追蹤 `Surface.queueBuffer()` → 確認 timestamp 設定
4. 追蹤 `MediaCodec.releaseOutputBuffer()` → 找到 timestamp 遺失

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 Surface/BufferQueue | 20% | 了解 timestamp 傳遞機制 |
| 理解 root cause | 25% | 能解釋 timestamp 遺失點 |
| 修復方案正確 | 15% | 正確傳遞 render timestamp |
| 無 side effect | 10% | 確保非 Surface 解碼正常 |

## 常見錯誤方向
- 認為是 SurfaceTexture 的問題
- 忽略 native 層的 Surface 互動
- 只看 MediaCodec 不追蹤到 Surface
