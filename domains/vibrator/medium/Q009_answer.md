# Q009 Answer: VibrationEffect Scale Factor Clamp Error

## 正確答案
**C**

## 問題根因
在 `VibrationEffect.OneShot` 的 `scale()` 方法中，
計算順序錯誤，先將 scale 轉為整數再乘以振幅，
導致 0.3 被截斷為 0，最終結果為 0。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public VibrationEffect scale(float scaleFactor) {
    // BUG: 整數除法導致 scaleFactor < 1 時為 0
    int scaledAmplitude = (int) scaleFactor * mAmplitude;
    return new OneShot(mDuration, clamp(scaledAmplitude, 1, 255));
}

// 正確的代碼
public VibrationEffect scale(float scaleFactor) {
    int scaledAmplitude = (int) (scaleFactor * mAmplitude);
    return new OneShot(mDuration, clamp(scaledAmplitude, 1, 255));
}
```

## 選項分析
- **A** clamp 函數邊界錯誤 — 錯誤，問題在計算不是 clamp
- **B** scaleFactor 被錯誤地限制在 [0,1] — 錯誤，沒有這個限制
- **C** 整數轉換發生在乘法之前 — ✅ 正確
- **D** mAmplitude 值未初始化 — 錯誤，200 是有效值

## 相關知識
- Java 的 `(int) a * b` 先轉換 a 再乘 b
- 應該用 `(int)(a * b)` 先乘後轉換
- 這是常見的運算優先順序錯誤

## 難度說明
**Medium** - 需要理解類型轉換的優先順序和運算順序。
