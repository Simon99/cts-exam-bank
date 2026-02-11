# Media-M-Q016 解答

## Root Cause
問題出在兩個檔案：

1. `MediaCodecList.java` 中 filter 邏輯錯誤：
```java
// 在 initCodecList() 中
// 錯誤：REGULAR_CODECS 時應該過濾 isSoftwareOnly，但邏輯顛倒
private void initCodecList(int kind) {
    if (kind == REGULAR_CODECS) {
        // Bug: 條件應該是 !isSoftwareOnly() 但寫成了 true
        // 導致所有 codec 都被加入
        for (MediaCodecInfo info : allCodecs) {
            mCodecInfos.add(info);  // 缺少過濾
        }
    }
}
```

2. `MediaCodecInfo.java` 中的 `isSoftwareOnly()` 也有輔助判斷問題。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodecList.java`
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`

## Bug Pattern
Pattern B（橫向多點）- 影響 2 個檔案

## 追蹤路徑
1. CTS log → REGULAR_CODECS 沒有正確過濾
2. 追蹤 `MediaCodecList` 建構子 → 發現 filter 邏輯問題
3. 檢查 `REGULAR_CODECS` vs `ALL_CODECS` 處理 → 找到缺失的過濾
4. 驗證 `isSoftwareOnly()` 判斷 → 確認過濾依據

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位主要 bug 檔案 | 30% | 找到 MediaCodecList.java |
| 找到次要相關檔案 | 20% | 找到 MediaCodecInfo.java |
| 理解 root cause | 25% | 能解釋 filter 邏輯問題 |
| 修復方案正確 | 15% | 加入正確的過濾條件 |
| 無 side effect | 10% | 確保 ALL_CODECS 不受影響 |

## 常見錯誤方向
- 只看 MediaCodecList 不看過濾條件來源
- 認為是 native 層 MediaCodecList.cpp 問題
- 忽略 REGULAR_CODECS 的語義定義
