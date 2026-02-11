# Media-M-Q020 解答

## Root Cause
問題出在兩個檔案：

1. `MediaCodecInfo.java` 中 profileLevels array 的建構：
```java
// 在 CodecCapabilities 建構子中
CodecProfileLevel[] profileLevels = new CodecProfileLevel[numProfileLevels];
for (int i = 0; i < numProfileLevels; i++) {
    // Bug: i 被錯誤地除以 2
    profileLevels[i / 2] = new CodecProfileLevel();  // 覆蓋前面的值
    profileLevels[i / 2].profile = profiles[i];
    profileLevels[i / 2].level = levels[i];
}
```

2. `MediaCodecList.cpp` 中取得 profile levels 的邏輯也有問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`
- `frameworks/av/media/libstagefright/MediaCodecList.cpp`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → profileLevels array 長度不正確
2. 追蹤 `getProfileLevels()` → 發現 array 大小異常
3. 追蹤 array 建構過程 → 找到索引錯誤
4. 檢查 native 層 → 確認資料傳遞正確性

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaCodecInfo.java |
| 找到次要相關檔案 | 20% | 找到 MediaCodecList.cpp |
| 理解 root cause | 25% | 能解釋索引計算錯誤 |
| 修復方案正確 | 15% | 修正 array 索引邏輯 |
| 無 side effect | 10% | 確保其他 codec 資訊不受影響 |

## 常見錯誤方向
- 認為是 codec driver 回報的資料有問題
- 忽略 array 索引的運算錯誤
- 只看 native 不看 Java 層的處理
