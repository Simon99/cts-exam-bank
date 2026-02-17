# Q005 Answer: CombinedVibration Synced Effects Order Error

## 正確答案
**C**

## 問題根因
在 `CombinedVibration.Synced` 類別的建構或執行邏輯中，
使用了 `descendingKeySet()` 而非 `keySet()` 遍歷振動器 Map，
導致執行順序與加入順序相反。

## Bug 位置
`frameworks/base/core/java/android/os/CombinedVibration.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public Synced(SparseArray<VibrationEffect> effects) {
    mEffects = new SparseArray<>();
    // BUG: 逆序遍歷
    for (int i = effects.size() - 1; i >= 0; i--) {
        mEffects.put(effects.keyAt(i), effects.valueAt(i));
    }
}

// 正確的代碼
public Synced(SparseArray<VibrationEffect> effects) {
    mEffects = new SparseArray<>();
    for (int i = 0; i < effects.size(); i++) {
        mEffects.put(effects.keyAt(i), effects.valueAt(i));
    }
}
```

## 選項分析
- **A** 振動器 ID 排序錯誤 — 錯誤，ID 本身沒問題
- **B** 同步訊號發送順序錯誤 — 錯誤，問題在集合遍歷
- **C** 使用逆序遍歷效果 Map — ✅ 正確
- **D** HAL 層同步失敗 — 錯誤，錯誤在 Framework 層

## 相關知識
- Synced vibration 要求多個振動器同時執行
- SparseArray 的遍歷順序影響執行順序
- 同步精度對觸覺體驗很重要

## 難度說明
**Hard** - 需要理解多振動器同步機制和集合遍歷順序的影響。
