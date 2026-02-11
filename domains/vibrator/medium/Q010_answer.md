# Q010 Answer: CombinedVibration Parallel Missing Effect

## 正確答案
**B**

## 問題根因
在 `CombinedVibration.java` 的 `createParallel()` 方法中，
建立 ParallelCombination 後沒有呼叫 `addVibrator()` 加入效果。

## Bug 位置
`frameworks/base/core/java/android/os/CombinedVibration.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public static CombinedVibration createParallel(VibrationEffect effect) {
    ParallelCombination parallel = new ParallelCombination();
    // BUG: 忘記加入效果
    return parallel.combine();
}

// 正確的代碼
public static CombinedVibration createParallel(VibrationEffect effect) {
    return new ParallelCombination()
            .addVibrator(DEFAULT_VIBRATOR_ID, effect)
            .combine();
}
```

## 選項分析
- **A** VibrationEffect 驗證失敗 — 錯誤，會有異常
- **B** 效果未被加入到 ParallelCombination — ✅ 正確
- **C** DEFAULT_VIBRATOR_ID 未定義 — 錯誤，會有編譯錯誤
- **D** combine() 清空了內容 — 錯誤，combine 不會清空

## 相關知識
- CombinedVibration 可包含多個振動器的效果
- createParallel() 是便利方法，針對單一效果
- ParallelCombination 使用 Builder pattern

## 難度說明
**Medium** - 需要理解 CombinedVibration 的建構流程和 Builder pattern。
