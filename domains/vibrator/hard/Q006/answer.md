# Q006 Answer: ParallelCombination Add Vibrator ID Validation

## 正確答案
**B**

## 問題根因
在 `CombinedVibration.ParallelCombination` 的 `addVibrator()` 方法中，
只驗證了 effect 參數不為 null，但沒有驗證 vibratorId 的有效性。

## Bug 位置
`frameworks/base/core/java/android/os/CombinedVibration.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public ParallelCombination addVibrator(int vibratorId, VibrationEffect effect) {
    Preconditions.checkNotNull(effect, "effect cannot be null");
    // BUG: 缺少 vibratorId 驗證
    mEffects.put(vibratorId, effect);
    return this;
}

// 正確的代碼
public ParallelCombination addVibrator(int vibratorId, VibrationEffect effect) {
    Preconditions.checkNotNull(effect, "effect cannot be null");
    if (vibratorId < 0) {
        throw new IllegalArgumentException("Vibrator ID must be non-negative: " + vibratorId);
    }
    mEffects.put(vibratorId, effect);
    return this;
}
```

## 選項分析
- **A** vibratorId 被自動取絕對值 — 錯誤，沒有這個操作
- **B** 缺少 vibratorId 的負數檢查 — ✅ 正確
- **C** SparseArray 允許負數 key — 技術上可以，但 API 應該驗證
- **D** 驗證被延遲到 combine() — 錯誤，combine() 也沒驗證

## 相關知識
- 振動器 ID 由 VibratorManager.getVibratorIds() 定義
- ID 必須是非負整數
- 無效 ID 會導致硬體操作失敗

## 難度說明
**Hard** - 需要理解多振動器架構和 ID 的有效性規則。
