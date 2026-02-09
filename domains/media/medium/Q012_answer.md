# Media-M-Q012 解答

## Root Cause
問題涉及兩個檔案：

1. `MediaExtractor.java` 中 `getTrackFormat()` 的 track index 處理：
```java
public MediaFormat getTrackFormat(int index) {
    // 錯誤：使用 (trackCount - 1 - index) 而非 index
    return new MediaFormat(getTrackFormatNative(mTrackCount - 1 - index));
}
```

2. Native 層的 track 索引對應在 `NuMediaExtractor.cpp` 中也可能有問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaExtractor.java`
- `frameworks/av/media/libstagefright/NuMediaExtractor.cpp` (需要確認)

## Bug Pattern
Pattern B（橫向多點）- 需要追蹤 Java 和 native 的交互

## 追蹤路徑
1. CTS log → track format 不匹配
2. 比較返回的 MIME type → video 和 audio 對調
3. 追蹤 `getTrackFormat()` → 發現 index 計算錯誤
4. 添加 log 確認 native 層接收到的 index

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 Java 層問題 | 35% | 找到 MediaExtractor.java 的 index 計算 |
| 能識別需要檢查 native 層 | 15% | 意識到 JNI 調用的 index 傳遞 |
| 理解 root cause | 25% | 能解釋 index 反轉導致 track 對調 |
| 修復方案正確 | 15% | 移除錯誤的 index 計算 |
| 無 side effect | 10% | 確保所有 track 操作正確 |

## 常見錯誤方向
- 只看 selectTrack 不看 getTrackFormat
- 認為是媒體檔案解析問題
- 去 muxer 或 codec 找問題
