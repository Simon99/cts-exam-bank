# Media-E-Q005 解答

## Root Cause
`MediaMuxer.java` 中 `OutputFormat` 常量值被交換。

原本：
```java
public static final int MUXER_OUTPUT_MPEG_4 = 0;
public static final int MUXER_OUTPUT_WEBM = 1;
```

被改成：
```java
public static final int MUXER_OUTPUT_MPEG_4 = 1;  // 交換
public static final int MUXER_OUTPUT_WEBM = 0;    // 交換
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaMuxer.java`

## Bug Pattern
Pattern A（縱向單點）- 常量值交換

## 追蹤路徑
1. CTS log → `MediaMuxer.java:252` 的 native setup 失敗
2. 查看錯誤訊息 → expected MP4 but got WebM
3. 追蹤 `MediaMuxer` 構造函數 → 發現傳入的 format 常量
4. 檢查 `OutputFormat` 常量定義 → 發現值被交換

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaMuxer.java |
| 正確定位 bug 位置 | 20% | OutputFormat 常量定義 |
| 理解 root cause | 20% | 能解釋 MPEG_4 和 WEBM 的值被交換 |
| 修復方案正確 | 10% | 交換回正確值 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 MPEG4Writer 找問題
- 檢查 muxer 初始化邏輯
- 追蹤文件頭寫入邏輯（問題在常量定義）
