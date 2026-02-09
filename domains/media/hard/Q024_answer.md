# Media-H-Q024 解答

## Root Cause
問題涉及三個檔案的 metadata 傳遞：

1. `MediaCodec.cpp` - HDR metadata 沒有傳給 encoder：
```cpp
// configure 時 HDR info 被忽略
sp<ABuffer> hdrInfo;
if (format->findBuffer(KEY_HDR10_PLUS_INFO, &hdrInfo)) {
    // Bug: 沒有傳給 codec
    // mCodec->setParameter(KEY_HDR10_PLUS_INFO, hdrInfo);
}
```

2. `HevcUtils.cpp` - SEI message 解析時丟棄 HDR10+ data：
```cpp
// 解析 SEI 時
// Bug: HDR10+ SEI type 被跳過
```

3. `MediaFormat.java` - getByteBuffer 對 HDR key 的處理問題。

## 涉及檔案
- `frameworks/av/media/libstagefright/MediaCodec.cpp`
- `frameworks/av/media/libstagefright/HevcUtils.cpp`
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → output frame 缺少 HDR10+ metadata
2. 追蹤 decode output → MediaFormat 沒有 KEY_HDR10_PLUS_INFO
3. 追蹤 SEI 解析 → HevcUtils 沒有處理 HDR10+ SEI
4. 追蹤 encode input → MediaCodec 沒有傳遞 HDR info

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 HDR10+ 規範 | 20% | 了解 dynamic metadata 傳遞 |
| 理解 root cause | 25% | 能解釋 metadata 丟失點 |
| 修復方案正確 | 15% | 正確傳遞 HDR metadata |
| 無 side effect | 10% | 確保 SDR 內容不受影響 |

## 常見錯誤方向
- 認為是 codec 不支援 HDR10+
- 忽略 SEI message 解析
- 只看 Java 層不追蹤 native 實作
