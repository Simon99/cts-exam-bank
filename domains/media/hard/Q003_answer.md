# Media-H-Q023 解答

## Root Cause
問題涉及三個檔案的 buffer 管理：

1. `MediaCodec.cpp` - resolution change 時 buffer pool 處理錯誤：
```cpp
// 解析度切換時應該 flush 並 reallocate buffer
// Bug: 沒有更新 buffer size
mOutputBufferPool->resize(mOutputFormat);  // 漏掉了
```

2. `CCodecBufferChannel.cpp` - 新 buffer 配置不正確：
```cpp
// 配置新解析度的 buffer 時
// Bug: 仍使用舊的 buffer size 導致 overflow
```

3. `MediaCodec.java` - Java 層沒有正確處理 format change event。

## 涉及檔案
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/av/media/codec2/sfplugin/CCodecBufferChannel.cpp`
- `frameworks/base/media/java/android/media/MediaCodec.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → resolution change 後 buffer 損壞
2. 分析 crash log → `CCodecBufferChannel::renderOutputBuffer` crash
3. 追蹤 buffer allocation → 發現 size mismatch
4. 追蹤 format change handling → 找到 resize 缺失

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 adaptive playback 機制 | 20% | 了解 buffer pool 管理 |
| 理解 root cause | 25% | 能解釋 buffer size mismatch |
| 修復方案正確 | 15% | 正確處理 buffer 重新配置 |
| 無 side effect | 10% | 確保非 adaptive 場景正確 |

## 常見錯誤方向
- 認為是 decoder 實作問題
- 忽略 Codec2 框架的 buffer channel
- 只看 Java 層的 format change 處理
