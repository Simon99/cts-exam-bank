# Media-E-Q008 解答

## Root Cause
`MediaExtractor.java` 中 `getTrackCount()` 方法被修改為固定返回 0。

原本：
```java
public native final int getTrackCount();
```

被改成：
```java
public final int getTrackCount() {
    return 0;  // 固定返回 0，不調用 native 方法
}

private native int nativeGetTrackCount();
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaExtractor.java`

## Bug Pattern
Pattern A（縱向單點）- 返回值錯誤

## 追蹤路徑
1. CTS log → `ExtractorTest.java:156` 的 `assertTrue` 失敗
2. 查看錯誤訊息 → track count 總是 0
3. 追蹤 `MediaExtractor.getTrackCount()` → 發現固定返回 0
4. 檢查方法是否調用了 native 方法

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaExtractor.java |
| 正確定位 bug 位置 | 20% | getTrackCount() 方法 |
| 理解 root cause | 20% | 能解釋方法沒有調用 native 實現 |
| 修復方案正確 | 10% | 恢復 native 方法調用 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 NuMediaExtractor 找問題
- 檢查媒體檔案解析邏輯
- 追蹤 track 發現和註冊流程
