# Q001 Answer: Frequency Control Check Returns Wrong Result

## 正確答案
**C**

## 問題根因
在 `Vibrator.java` 的 `hasFrequencyControl()` 方法中，
錯誤地呼叫了 `hasAmplitudeControl()` 而非檢查 FrequencyProfile 是否為空。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public boolean hasFrequencyControl() {
    return getInfo().hasAmplitudeControl();  // BUG: 檢查錯誤的能力
}

// 正確的代碼
public boolean hasFrequencyControl() {
    return !getInfo().getFrequencyProfile().isEmpty();
}
```

## 選項分析
- **A** FrequencyProfile 未正確初始化 — 錯誤，log 顯示 profile 是有效的
- **B** 硬體驅動回報錯誤的能力 — 錯誤，VibratorInfo 顯示正確
- **C** 方法內呼叫了錯誤的檢查函數 — ✅ 正確
- **D** 需要特殊權限才能查詢頻率控制 — 錯誤，不需要權限

## 相關知識
- 頻率控制允許調整振動頻率（Hz）
- FrequencyProfile 定義了裝置支援的頻率範圍
- 振幅控制與頻率控制是不同的硬體能力

## 難度說明
**Medium** - 需要理解 hasAmplitudeControl 和 hasFrequencyControl 的區別，並注意呼叫的方法。
