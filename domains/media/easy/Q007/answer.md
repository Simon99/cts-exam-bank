# Media-E-Q007 解答

## Root Cause
`MediaFormat.java` 中處理 `KEY_CHANNEL_COUNT` 時，返回值被強制設為 0。

原本：
```java
public int getInteger(@NonNull String name) {
    return ((Integer)mMap.get(name)).intValue();
}
```

被改成：
```java
public int getInteger(@NonNull String name) {
    if (KEY_CHANNEL_COUNT.equals(name)) {
        return 0;  // 固定返回 0
    }
    return ((Integer)mMap.get(name)).intValue();
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern A（縱向單點）- 返回值錯誤

## 追蹤路徑
1. CTS log → `AudioEncoderTest.java:195` 的 `assertEquals` 失敗
2. 查看錯誤訊息 → channel count 總是返回 0
3. 追蹤 `MediaFormat.getInteger(KEY_CHANNEL_COUNT)` → 發現固定返回 0
4. 檢查 `MediaFormat.java` 的 `getInteger()` 方法

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaFormat.java |
| 正確定位 bug 位置 | 20% | getInteger() 中 KEY_CHANNEL_COUNT 處理 |
| 理解 root cause | 20% | 能解釋 channel count 被固定返回 0 |
| 修復方案正確 | 10% | 移除錯誤的條件判斷 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 AudioTrack 或 AudioFormat 找問題
- 檢查 codec 的 channel 配置
- 追蹤 native 層的音頻格式設置
