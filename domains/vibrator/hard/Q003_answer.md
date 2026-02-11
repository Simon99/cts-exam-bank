# Q003 Answer: Composition Compose Empty State Error

## 正確答案
**A**

## 問題根因
在 `VibrationEffect.Composition` 的 `compose()` 方法中，
空 Composition 的檢查條件被反轉，使用 `!isEmpty()` 判斷拋出異常，
導致非空時拋出異常而空時通過。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public VibrationEffect compose() {
    // BUG: 條件反轉，非空時拋異常
    if (!mPrimitives.isEmpty()) {
        throw new IllegalStateException("Composition must have at least one primitive");
    }
    return new Composed(mPrimitives);
}

// 正確的代碼
public VibrationEffect compose() {
    if (mPrimitives.isEmpty()) {
        throw new IllegalStateException("Composition must have at least one primitive");
    }
    return new Composed(mPrimitives);
}
```

## 選項分析
- **A** isEmpty() 檢查條件被反轉（使用 !） — ✅ 正確
- **B** mPrimitives 未正確初始化 — 錯誤，初始化正常
- **C** compose() 可被重複呼叫 — 錯誤，與本問題無關
- **D** 異常類型錯誤 — 錯誤，IllegalStateException 是正確類型

## 相關知識
- Composition 必須包含至少一個原語
- compose() 是終結方法，產生最終的 VibrationEffect
- 狀態驗證確保物件有效性

## 難度說明
**Hard** - 需要理解 Composition 的狀態管理和 compose() 的驗證邏輯。
