# Media-E-Q004 解答

## Root Cause
`MediaFormat.java` 中處理 `KEY_SAMPLE_RATE` 時，返回值被除以 2。

原本：
```java
public int getInteger(@NonNull String name) {
    return ((Integer)mMap.get(name)).intValue();
}
```

被改成：
```java
public int getInteger(@NonNull String name) {
    int value = ((Integer)mMap.get(name)).intValue();
    if (KEY_SAMPLE_RATE.equals(name)) {
        return value / 2;  // 錯誤地除以 2
    }
    return value;
}
```

## 涉及檔案
- `frameworks/base/media/java/android/media/MediaFormat.java`

## Bug Pattern
Pattern A（縱向單點）- 數值計算錯誤

## 追蹤路徑
1. CTS log → `AudioEncoderTest.java:189` 的 `assertEquals` 失敗
2. 查看錯誤訊息 → sample rate 是預期值的一半 (44100 → 22050)
3. 追蹤 `MediaFormat.getInteger(KEY_SAMPLE_RATE)` → 發現返回值被除以 2
4. 檢查 `MediaFormat.java` 的 `getInteger()` 方法

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 正確定位 bug 檔案 | 40% | 找到 MediaFormat.java |
| 正確定位 bug 位置 | 20% | getInteger() 方法中的 KEY_SAMPLE_RATE 處理 |
| 理解 root cause | 20% | 能解釋 sample rate 被除以 2 |
| 修復方案正確 | 10% | 移除錯誤的除法運算 |
| 無 side effect | 10% | 修改不影響其他功能 |

## 常見錯誤方向
- 去 AudioTrack 或 AudioRecord 找問題
- 檢查 codec 的 sample rate 配置
- 追蹤 native 層的音頻處理邏輯
