# Q010 Answer: CombinedVibration Parallel Empty Effects Validation

## 正確答案
**C**

## 問題根因
在 `CombinedVibration.java` 的 `ParallelCombination.combine()` 方法中，
沒有檢查 mEffects 是否為空就直接建構 CombinedVibration 物件。
應該在 combine() 時驗證至少加入了一個振動器。

## Bug 位置
`frameworks/base/core/java/android/os/CombinedVibration.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public CombinedVibration combine() {
    // BUG: 沒有檢查 mEffects 是否為空
    return new CombinedVibration.Parallel(mEffects);
}

// 正確的代碼
public CombinedVibration combine() {
    if (mEffects.isEmpty()) {
        throw new IllegalStateException(
                "ParallelCombination must have at least one vibrator effect");
    }
    return new CombinedVibration.Parallel(mEffects);
}
```

## 選項分析
- **A** mEffects 初始化為 null — 錯誤，初始化為空 SparseArray
- **B** addVibrator 沒有加入效果 — 錯誤，addVibrator 正常運作
- **C** combine() 缺少空集合檢查 — ✅ 正確
- **D** Parallel 建構函數接受空集合 — 錯誤，問題在 combine

## 相關知識
- ParallelCombination 是 Builder 模式
- 必須至少加入一個振動器效果才能組合
- Builder 的 build/combine 方法應驗證最終狀態

## 難度說明
**Hard** - 需要理解 Builder 模式和狀態驗證，識別缺失的完整性檢查。
