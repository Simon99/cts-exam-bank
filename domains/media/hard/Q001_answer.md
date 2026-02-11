# Media-H-Q021 解答

## Root Cause
問題出在三個檔案的交互：

1. `MediaCodec.java` - output buffer flags 處理問題：
```java
// dequeueOutputBuffer 時遺失 KEY_FRAME flag
BufferInfo info = new BufferInfo();
// Bug: flags 被清除，導致 muxer 無法識別 keyframe
info.flags = 0;  // 應該保留原始 flags
```

2. `MediaMuxer.java` - writeSampleData 對 keyframe 的依賴：
```java
// 第一個 sample 必須是 keyframe，否則不寫入
if (!mFirstKeyFrameReceived && (info.flags & BUFFER_FLAG_KEY_FRAME) == 0) {
    return;  // 丟棄 sample
}
```

3. `MediaExtractor.java` - 讀取時 track format 校驗失敗。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodec.java`
- `frameworks/base/media/java/android/media/MediaMuxer.java`
- `frameworks/base/media/java/android/media/MediaExtractor.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → extract 時無法讀取 sample
2. 檢查輸出檔案 → 只有 header 無 video data
3. 追蹤 `MediaMuxer.writeSampleData()` → 發現 sample 被丟棄
4. 追蹤 encoder output → 發現 flags 被清除
5. 追蹤 BufferInfo → 找到 flags 初始化問題

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解資料流向 | 20% | encoder → muxer → extractor |
| 理解 root cause | 25% | 能解釋 flags 遺失導致的連鎖反應 |
| 修復方案正確 | 15% | 正確保留 buffer flags |
| 無 side effect | 10% | 確保其他 codec 用例不受影響 |

## 常見錯誤方向
- 只看 muxer 不追蹤 encoder 輸出
- 認為是檔案系統寫入問題
- 忽略 keyframe flag 的重要性
