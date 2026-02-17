# Media-E-Q002 解答

## Root Cause
`MediaCodecInfo.java` 中 `isEncoder()` 方法返回值被取反。

原本：
```java
public final boolean isEncoder() {
    return (mFlags & FLAG_IS_ENCODER) != 0;
}
```

被改成：
```java
public final boolean isEncoder() {
    return (mFlags & FLAG_IS_ENCODER) == 0;  // != 改成 ==
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`

## Bug Pattern
Pattern A（縱向單點）- 邏輯運算符錯誤

## 追蹤路徑
1. CTS log → `CodecInfoTest.java:156` 的 `assertFalse` 失敗
2. 查看錯誤訊息 → decoder 被識別為 encoder
3. 追蹤 `MediaCodecInfo.isEncoder()` → 發現返回值相反
4. 檢查 `MediaCodecInfo.java` 的 `isEncoder()` 方法 → 找到邏輯運算符錯誤

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaCodecInfo.java |
| 正確定位 bug 位置 | 20% | isEncoder() 方法 |
| 理解 root cause | 20% | 能解釋 != 被改成 == 導致返回值取反 |
| 修復方案正確 | 10% | 將 == 改回 != |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 MediaCodecList 找問題
- 檢查 codec 註冊流程
- 追蹤 mFlags 的設置邏輯（問題不在設置而在讀取）
