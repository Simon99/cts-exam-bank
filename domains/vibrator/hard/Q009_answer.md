# Q009 Answer: VibrationEffect Scale Factor Calculation Error

## 正確答案
**A**

## 問題根因
在 `VibrationEffect.java` 的 `scale(float)` 方法中，
計算後沒有返回新的縮放效果，而是返回了 `this`（原始效果）。
VibrationEffect 是 immutable 的，scale 應該創建並返回新物件。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public VibrationEffect scale(float scaleFactor) {
    if (scaleFactor <= 0 || scaleFactor > 1.0f) {
        throw new IllegalArgumentException("scaleFactor out of range");
    }
    // 計算縮放後的振幅...
    int newAmplitude = (int) (mAmplitude * scaleFactor);
    // BUG: 返回 this 而非新物件
    return this;
}

// 正確的代碼
public VibrationEffect scale(float scaleFactor) {
    if (scaleFactor <= 0 || scaleFactor > 1.0f) {
        throw new IllegalArgumentException("scaleFactor out of range");
    }
    int newAmplitude = (int) (mAmplitude * scaleFactor);
    return new OneShot(mDuration, newAmplitude);
}
```

## 選項分析
- **A** 返回 this 而非新建物件 — ✅ 正確
- **B** scaleFactor 被截斷為整數 — 錯誤，計算中使用 float
- **C** amplitude 使用加法而非乘法 — 錯誤，用的是乘法
- **D** 縮放結果溢位 — 錯誤，128*0.5 不會溢位

## 相關知識
- VibrationEffect 是 immutable 類別
- scale() 應該返回新的 VibrationEffect 實例
- 類似 String 的設計：修改操作返回新物件

## 難度說明
**Hard** - 需要理解 immutable 設計模式，識別返回值錯誤。
