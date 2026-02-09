# Media-M-Q011 解答

## Root Cause
問題出在兩個檔案：

1. `MediaCodec.java` 中 configure 時對 `COLOR_FormatYUV420Flexible` 的處理：
```java
// 在 configure() 中
if (format.containsKey(KEY_COLOR_FORMAT)) {
    int colorFormat = format.getInteger(KEY_COLOR_FORMAT);
    if (colorFormat == COLOR_FormatYUV420Flexible) {
        // 錯誤地映射到 Planar 而非保持 Flexible
        format.setInteger(KEY_COLOR_FORMAT, COLOR_FormatYUV420Planar);
    }
}
```

2. `MediaCodecInfo.java` 中 `CodecCapabilities` 對 flexible format 的支援判斷也有問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → color format 不符合預期
2. 追蹤 `MediaCodec.configure()` → 發現 format 被修改
3. 查看 `KEY_COLOR_FORMAT` 的處理邏輯 → 找到錯誤映射
4. 檢查 `MediaCodecInfo.CodecCapabilities` → 確認支援判斷邏輯

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaCodec.java |
| 找到次要相關檔案 | 20% | 找到 MediaCodecInfo.java |
| 理解 root cause | 25% | 能解釋 Flexible 被映射到 Planar |
| 修復方案正確 | 15% | 移除錯誤的映射邏輯 |
| 無 side effect | 10% | 確保其他 color format 不受影響 |

## 常見錯誤方向
- 只看 MediaCodec 不看 MediaCodecInfo
- 去 native 層 ACodec 找問題
- 認為是 codec 實作問題而非 framework 問題
