# Q007 Answer: Keyboard Vibration Default Check Failed

## 正確答案
**A**

## 問題根因
在 `Vibrator.java` 的 `isDefaultKeyboardVibrationEnabled()` 方法中，
從設定讀取的布林值被錯誤地反轉（使用 `!` 運算符）。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public boolean isDefaultKeyboardVibrationEnabled() {
    return !mVibrationConfig.isDefaultKeyboardVibrationEnabled();  // BUG: 不應該反轉
}

// 正確的代碼
public boolean isDefaultKeyboardVibrationEnabled() {
    return mVibrationConfig.isDefaultKeyboardVibrationEnabled();
}
```

## 選項分析
- **A** 回傳值被反轉（使用 !） — ✅ 正確
- **B** 設定值讀取失敗 — 錯誤，會有其他異常
- **C** VibrationConfig 版本不相容 — 錯誤，會有編譯錯誤
- **D** 權限不足無法讀取設定 — 錯誤，會拋出 SecurityException

## 相關知識
- 鍵盤振動是輸入法觸覺反饋功能
- 使用者可在系統設定中開關此功能
- 應用程式應尊重使用者的偏好設定

## 難度說明
**Easy** - 回傳值完全相反，檢查實作時 `!` 運算符很明顯。
