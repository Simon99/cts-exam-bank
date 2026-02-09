# Media-E-Q006 解答

## Root Cause
`MediaCodecInfo.java` 中 `isSoftwareOnly()` 方法使用了錯誤的 flag。

原本：
```java
public final boolean isSoftwareOnly() {
    return (mFlags & FLAG_IS_SOFTWARE_ONLY) != 0;
}
```

被改成：
```java
public final boolean isSoftwareOnly() {
    return (mFlags & FLAG_IS_HARDWARE_ACCELERATED) != 0;  // 用錯 flag
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`

## Bug Pattern
Pattern A（縱向單點）- 使用錯誤 flag

## 追蹤路徑
1. CTS log → `CodecInfoTest.java:178` 的 `assertFalse` 失敗
2. 查看錯誤訊息 → hardware accelerated codec 被識別為 software only
3. 追蹤 `MediaCodecInfo.isSoftwareOnly()` → 發現使用了錯誤的 flag
4. 檢查 flag 定義 → 確認 FLAG_IS_SOFTWARE_ONLY 和 FLAG_IS_HARDWARE_ACCELERATED 不同

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaCodecInfo.java |
| 正確定位 bug 位置 | 20% | isSoftwareOnly() 方法 |
| 理解 root cause | 20% | 能解釋使用了錯誤的 FLAG_IS_HARDWARE_ACCELERATED |
| 修復方案正確 | 10% | 改回 FLAG_IS_SOFTWARE_ONLY |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 native 層 MediaCodecList 找 flag 設置邏輯
- 檢查 codec 註冊和屬性設置流程
- 追蹤 mFlags 的初始化邏輯
