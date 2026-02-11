# Media-M-Q019 解答

## Root Cause
問題出在兩個檔案：

1. `MediaCodec.java` 中的 format cache 更新邏輯：
```java
// 在 handleCallback 中
case EVENT_OUTPUT_FORMAT_CHANGED:
    // Bug: 沒有更新 mOutputFormat
    // mOutputFormat = msg.getData().getParcelable("format");
    listener.onOutputFormatChanged(this, mOutputFormat);  // 返回舊的
    break;
```

2. `MediaCodec.cpp` 中 format 更新事件處理也有問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/av/media/libstagefright/MediaCodec.cpp`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → getOutputFormat() 返回舊值
2. 追蹤 `MediaCodec.getOutputFormat()` → 發現返回 cached format
3. 追蹤 format change callback → 發現 cache 未更新
4. 檢查 native 層 → 確認事件傳遞正確性

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaCodec.java |
| 找到次要相關檔案 | 20% | 找到 MediaCodec.cpp |
| 理解 root cause | 25% | 能解釋 format cache 未更新 |
| 修復方案正確 | 15% | 正確更新 mOutputFormat |
| 無 side effect | 10% | 確保同步與異步模式都正確 |

## 常見錯誤方向
- 認為是 codec 本身沒有發送 format change
- 忽略 Java 層的 format caching
- 只看 native 層不看 Java callback handler
