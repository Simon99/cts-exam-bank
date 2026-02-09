# Media-M-Q013 解答

## Root Cause
問題涉及 `AudioFormat.java` 和 `MediaFormat.java` 之間的 PCM encoding 映射：

1. `AudioFormat.java` 中 encoding 常量被交換：
```java
public static final int ENCODING_PCM_16BIT = 4;  // 原本是 2
public static final int ENCODING_PCM_FLOAT = 2;  // 原本是 4
```

2. `MediaFormat.java` 中 `KEY_PCM_ENCODING` 的處理依賴這些常量值。

## 涉及檔案
- `frameworks/base/media/java/android/media/AudioFormat.java`
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern B（橫向多點）- 常量值不一致導致跨檔案問題

## 追蹤路徑
1. CTS log → PCM encoding 值不匹配
2. 比較常量值 → FLOAT=4 變成 FLOAT=2
3. 追蹤 `AudioFormat.ENCODING_*` 常量定義
4. 檢查 `MediaFormat.KEY_PCM_ENCODING` 的使用

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 AudioFormat 問題 | 35% | 找到常量值被交換 |
| 找到 MediaFormat 相關性 | 15% | 理解兩者的關聯 |
| 理解 root cause | 25% | 能解釋常量值交換的影響 |
| 修復方案正確 | 15% | 交換回正確值 |
| 無 side effect | 10% | 確保音頻功能正常 |

## 常見錯誤方向
- 只看 MediaFormat 不看 AudioFormat
- 去 native 層找 PCM 處理問題
- 認為是 codec 實作問題
