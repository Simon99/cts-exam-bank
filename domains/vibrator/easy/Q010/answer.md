# Q010 Answer: VibrationEffect Duration Calculation Error

## 正確答案
**A**

## 問題根因
在 `VibrationEffect.OneShot` 類別的 `getDuration()` 方法中，
回傳了錯誤的成員變數 `mAmplitude` 而非 `mDuration`。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼（OneShot 內部類別）
@Override
public long getDuration() {
    return mAmplitude;  // BUG: 應該回傳 mDuration
}

// 正確的代碼
@Override
public long getDuration() {
    return mDuration;
}
```

## 選項分析
- **A** 回傳了 mAmplitude 而非 mDuration — ✅ 正確
- **B** Duration 未在建構時初始化 — 錯誤，建構函數有正確設定
- **C** getDuration() 未被覆寫 — 錯誤，有覆寫但實作錯誤
- **D** 時間單位轉換錯誤 — 錯誤，回傳 0 不符合轉換錯誤的模式

## 相關知識
- OneShot 有兩個主要成員：mDuration（持續時間）和 mAmplitude（振幅）
- getDuration() 對波形計算和排程很重要
- 這類錯誤常發生在複製貼上或自動完成時

## 難度說明
**Easy** - 回傳 0 而非預期值，檢查回傳語句即可發現變數名稱錯誤。
