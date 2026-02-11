# Q008 Answer: Composition Primitive Scale Boundary Validation

## 正確答案
**D**

## 問題根因
在 `VibrationEffect.java` 的 `Composition.addPrimitive(int, float)` 方法中，
上界檢查缺失，只檢查了 `scale < 0`，沒有檢查 `scale > 1.0f`。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public Composition addPrimitive(int primitiveId, float scale) {
    // BUG: 只檢查下界，沒檢查上界
    if (scale < 0) {
        throw new IllegalArgumentException("scale must be between 0 and 1");
    }
    mSegments.add(new PrimitiveSegment(primitiveId, scale, 0));
    return this;
}

// 正確的代碼
public Composition addPrimitive(int primitiveId, float scale) {
    if (scale < 0 || scale > 1.0f) {
        throw new IllegalArgumentException("scale must be between 0 and 1");
    }
    mSegments.add(new PrimitiveSegment(primitiveId, scale, 0));
    return this;
}
```

## 選項分析
- **A** primitiveId 沒有驗證 — 錯誤，primitiveId 有單獨驗證
- **B** Float.NaN 導致比較失敗 — 錯誤，測試用例是 1.5f
- **C** scale 被自動截斷到 1.0 — 錯誤，應該拋異常
- **D** 只檢查下界沒檢查上界 — ✅ 正確

## 相關知識
- scale 範圍 [0.0, 1.0]
- 0.0 表示最小強度（可能無感）
- 1.0 表示原語的完整強度
- 應該驗證雙邊界

## 難度說明
**Hard** - 需要理解組合 API 的設計，分析不完整的邊界檢查。
