# Q006 Answer: Composition Add Primitive Scale Validation Failed

## 正確答案
**B**

## 問題根因
在 `VibrationEffect.Composition` 的 `addPrimitive()` 方法中，
只檢查了 scale >= 0，但遺漏了 scale <= 1.0 的上界檢查。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public Composition addPrimitive(int primitiveId, float scale) {
    if (scale < 0f) {  // BUG: 缺少上界檢查
        throw new IllegalArgumentException("scale must be >= 0");
    }
    mPrimitives.add(new PrimitiveSegment(primitiveId, scale, 0));
    return this;
}

// 正確的代碼
public Composition addPrimitive(int primitiveId, float scale) {
    if (scale < 0f || scale > 1f) {
        throw new IllegalArgumentException("scale must be between 0 and 1");
    }
    mPrimitives.add(new PrimitiveSegment(primitiveId, scale, 0));
    return this;
}
```

## 選項分析
- **A** primitiveId 驗證缺失 — 錯誤，問題是 scale
- **B** scale 上界 1.0 檢查缺失 — ✅ 正確
- **C** scale 下界 0 檢查缺失 — 錯誤，下界有檢查
- **D** Composition 狀態錯誤 — 錯誤，問題在驗證邏輯

## 相關知識
- scale 範圍 [0, 1.0]，用於縮放原語強度
- 0 = 無效果，1.0 = 最大強度
- 超過 1.0 可能導致硬體行為未定義

## 難度說明
**Medium** - 需要理解 scale 的有效範圍，並分析驗證條件的完整性。
