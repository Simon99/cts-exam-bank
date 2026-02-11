# Media-H-Q026 解答

## Root Cause
問題涉及三個檔案的 interleave 處理：

1. `MPEG4Writer.cpp` - track writer 順序錯誤：
```cpp
// 寫入 sample 時沒有按 timestamp 排序
// Bug: 按 track 順序寫入而非 timestamp 順序
for (auto& track : mTracks) {
    track->writePendingSamples();  // 應該按 pts 交錯
}
```

2. `MediaMuxer.cpp` - sample buffer 管理問題：
```cpp
// Sample 被緩存但沒有交錯輸出
```

3. `MediaMuxer.java` - Java 層 track 管理問題。

## 涉及檔案
- `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
- `frameworks/av/media/libstagefright/MediaMuxer.cpp`
- `frameworks/base/media/java/android/media/MediaMuxer.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → samples 沒有 interleave
2. 分析輸出檔案 → 確認所有 audio 在 video 前面
3. 追蹤 `MPEG4Writer::threadFunc()` → 發現寫入順序問題
4. 追蹤 sample buffering → 找到排序邏輯缺失

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 interleave 機制 | 20% | 了解 MPEG4 sample 交錯 |
| 理解 root cause | 25% | 能解釋寫入順序問題 |
| 修復方案正確 | 15% | 恢復正確的 interleave 邏輯 |
| 無 side effect | 10% | 確保單 track 場景正確 |

## 常見錯誤方向
- 認為是 container format 問題
- 忽略 MPEG4Writer 的 thread 模型
- 只看 Java 層 API 呼叫順序
