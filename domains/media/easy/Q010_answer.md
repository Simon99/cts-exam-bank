# Media-E-Q010 解答

## Root Cause
`MediaCodecInfo.java` 中 `isHardwareAccelerated()` 方法被修改為與 `isSoftwareOnly()` 返回相同結果。

原本：
```java
public final boolean isHardwareAccelerated() {
    return (mFlags & FLAG_IS_HARDWARE_ACCELERATED) != 0;
}
```

被改成：
```java
public final boolean isHardwareAccelerated() {
    return (mFlags & FLAG_IS_SOFTWARE_ONLY) != 0;  // 用錯 flag
}
```

這導致 `isHardwareAccelerated()` 和 `isSoftwareOnly()` 返回相同結果，違反互斥性。

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaCodecInfo.java`

## Bug Pattern
Pattern A（縱向單點）- 使用錯誤 flag

## 追蹤路徑
1. CTS log → `CodecInfoTest.java:203` 的 `assertFalse` 失敗
2. 查看錯誤訊息 → 兩個互斥屬性同時為 true
3. 追蹤 `isHardwareAccelerated()` 和 `isSoftwareOnly()` → 發現使用相同 flag
4. 檢查 flag 定義 → 確認應使用不同的 flag

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaCodecInfo.java |
| 正確定位 bug 位置 | 20% | isHardwareAccelerated() 方法 |
| 理解 root cause | 20% | 能解釋兩個方法使用了相同的 flag |
| 修復方案正確 | 10% | 改回 FLAG_IS_HARDWARE_ACCELERATED |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 嘗試修改 isSoftwareOnly() 而非 isHardwareAccelerated()
- 去 native 層找 flag 設置邏輯
- 檢查 codec 註冊流程
