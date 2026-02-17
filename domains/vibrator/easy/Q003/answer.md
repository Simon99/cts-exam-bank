# Q003 Answer: Basic Vibration Duration Error

## 正確答案
**A**

## 問題根因
在振動請求處理時，毫秒值被錯誤地除以 10，導致振動時間縮短為原本的 1/10。
這是時間單位轉換的錯誤。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public void vibrate(long milliseconds) {
    vibrate(VibrationEffect.createOneShot(milliseconds / 10,  // BUG: 不應該除以 10
            VibrationEffect.DEFAULT_AMPLITUDE));
}

// 正確的代碼
public void vibrate(long milliseconds) {
    vibrate(VibrationEffect.createOneShot(milliseconds,
            VibrationEffect.DEFAULT_AMPLITUDE));
}
```

## 選項分析
- **A** 毫秒值被除以 10 — ✅ 正確，500/10=50 符合錯誤現象
- **B** 振動器硬體延遲 — 錯誤，硬體延遲不會導致 10 倍差異
- **C** VibrationEffect 建立失敗 — 錯誤，會導致完全無振動
- **D** 權限被拒絕 — 錯誤，權限問題會拋出 SecurityException

## 相關知識
- `vibrate(long)` 是最基本的振動 API
- 內部會轉換為 `VibrationEffect.createOneShot()`
- 時間單位統一使用毫秒

## 難度說明
**Easy** - 10 倍的時間差異明確指向數值運算問題，直接定位除法運算即可。
