# Media-H-Q022 解答

## Root Cause
問題涉及三個檔案的 PTS 處理：

1. `MPEG4Writer.cpp` - video track 的 timestamp 計算錯誤：
```cpp
// 計算 video sample 的 PTS 時
int64_t pts = sampleTimeUs + 500000;  // Bug: 多加了 500ms offset
```

2. `MediaMuxer.cpp` - 沒有對齊 audio/video 的起始時間：
```cpp
// 應該記錄第一個 sample 的時間作為 base
// Bug: video track 用了錯誤的 base time
```

3. `MediaMuxer.java` - Java 層傳遞 PTS 時的問題。

## 涉及檔案
- `frameworks/av/media/libstagefright/MPEG4Writer.cpp`
- `frameworks/av/media/libstagefright/MediaMuxer.cpp`
- `frameworks/base/media/java/android/media/MediaMuxer.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案

## 追蹤路徑
1. CTS log → 發現 video PTS 偏移 500ms
2. 分析 PTS 數列 → 確認 audio 正確、video 有固定 offset
3. 追蹤 `MPEG4Writer::addSample()` → 找到額外的 offset 計算
4. 追蹤 base time 設定 → 確認跨 track 的時間對齊邏輯

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位所有相關檔案 | 30% | 找到全部 3 個檔案 |
| 理解 A/V 同步機制 | 20% | 了解 PTS 對齊原理 |
| 理解 root cause | 25% | 能解釋 offset 來源 |
| 修復方案正確 | 15% | 移除錯誤的 offset 計算 |
| 無 side effect | 10% | 確保其他 mux 場景正確 |

## 常見錯誤方向
- 認為是 audio encoder 的問題
- 只看 Java 層不深入 native 層
- 忽略 MPEG4Writer 的特定 track 處理
