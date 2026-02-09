# Media-M-Q018 解答

## Root Cause
問題出在兩個檔案：

1. `MediaExtractor.java` 中 seek mode 常數定義錯誤：
```java
// seek mode 常數值交換
public static final int SEEK_TO_PREVIOUS_SYNC = 0;  // 原本是 0
public static final int SEEK_TO_NEXT_SYNC = 1;      // 原本是 1
// Bug: 這兩個值被交換了
```

2. `NuMediaExtractor.cpp` 中處理 seek mode 的邏輯有對應問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaExtractor.java`
- `frameworks/av/media/libstagefright/NuMediaExtractor.cpp`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → SEEK_TO_PREVIOUS_SYNC 行為像 NEXT_SYNC
2. 追蹤 `MediaExtractor.seekTo()` → 檢查 mode 參數
3. 比對 Java 和 native 層的常數定義 → 發現值被交換
4. 追蹤 `NuMediaExtractor::seekTo()` → 確認 native 處理邏輯

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaExtractor.java |
| 找到次要相關檔案 | 20% | 找到 NuMediaExtractor.cpp |
| 理解 root cause | 25% | 能解釋 mode 常數交換問題 |
| 修復方案正確 | 15% | 恢復正確的常數值 |
| 無 side effect | 10% | 確保其他 seek mode 不受影響 |

## 常見錯誤方向
- 認為是 demuxer 實作問題
- 忽略 Java 和 native 常數必須一致
- 去找 codec 或 muxer 相關程式碼
