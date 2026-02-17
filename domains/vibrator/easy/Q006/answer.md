# Q006 Answer: Default Vibration Intensity Wrong Value

## 正確答案
**C**

## 問題根因
在 `Vibrator.java` 的 `getDefaultVibrationIntensity()` 方法中，
當從設定取得值失敗時，fallback 值被錯誤設為 -1 而非有效的預設強度。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public int getDefaultVibrationIntensity(int usage) {
    int intensity = mVibrationConfig.getDefaultVibrationIntensity(usage);
    return intensity != 0 ? intensity : -1;  // BUG: fallback 應該是 MEDIUM
}

// 正確的代碼
public int getDefaultVibrationIntensity(int usage) {
    int intensity = mVibrationConfig.getDefaultVibrationIntensity(usage);
    return intensity != 0 ? intensity : VIBRATION_INTENSITY_MEDIUM;
}
```

## 選項分析
- **A** usage 參數無效 — 錯誤，USAGE_RINGTONE 是有效的 usage
- **B** VibrationConfig 未初始化 — 錯誤，會導致 NullPointerException
- **C** Fallback 值設為 -1 而非有效強度 — ✅ 正確
- **D** 硬體不支援強度查詢 — 錯誤，此 API 不依賴硬體

## 相關知識
- 振動強度分為 OFF/LOW/MEDIUM/HIGH 四級
- 不同 usage（鈴聲、通知、觸控等）可有不同預設強度
- 強度設定影響振動的實際力度

## 難度說明
**Easy** - -1 是明顯的無效值，追蹤回傳邏輯即可發現問題。
