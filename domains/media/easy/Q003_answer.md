# Media-E-Q003 解答

## Root Cause
`MediaExtractor.java` 中 native 方法返回的 sample time 被取負值。

在 Java wrapper 層：
```java
public long getSampleTime() {
    return -nativeGetSampleTime();  // 添加了負號
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaExtractor.java`

## Bug Pattern
Pattern A（縱向單點）- 數值符號錯誤

## 追蹤路徑
1. CTS log → `ExtractorTest.java:423` 的 `assertTrue` 失敗
2. 查看錯誤訊息 → timestamp 是負值 (-33333)
3. 33333 微秒 = 30fps 視頻的一幀時間，說明值本身正確但符號錯誤
4. 追蹤 `MediaExtractor.getSampleTime()` → 發現返回值被取負

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaExtractor.java |
| 正確定位 bug 位置 | 20% | getSampleTime() 方法 |
| 理解 root cause | 20% | 能解釋返回值被取負導致 timestamp 為負數 |
| 修復方案正確 | 10% | 移除負號 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 NuMediaExtractor 找問題
- 檢查媒體檔案解析邏輯
- 追蹤 PTS 計算流程（問題在 Java wrapper 層）
