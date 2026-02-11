# Q002 Answer: Composition Primitive Delay Accumulation Error

## 正確答案
**B**

## 問題根因
在 `VibrationEffect.Composed` 類別的 `getDuration()` 方法中，
計算總延遲的迴圈從索引 1 開始而非 0，導致第一個原語的延遲被跳過。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
@Override
public long getDuration() {
    long duration = 0;
    // BUG: 從 1 開始，跳過第一個
    for (int i = 1; i < mPrimitives.size(); i++) {
        PrimitiveSegment segment = mPrimitives.get(i);
        duration += segment.getDuration() + segment.getDelay();
    }
    return duration;
}

// 正確的代碼
@Override
public long getDuration() {
    long duration = 0;
    for (int i = 0; i < mPrimitives.size(); i++) {
        PrimitiveSegment segment = mPrimitives.get(i);
        duration += segment.getDuration() + segment.getDelay();
    }
    return duration;
}
```

## 選項分析
- **A** PrimitiveSegment.getDelay() 回傳錯誤值 — 錯誤，log 顯示是累加問題
- **B** 迴圈從索引 1 開始，跳過第一個原語 — ✅ 正確
- **C** 延遲和持續時間相加順序錯誤 — 錯誤，順序不影響總和
- **D** 浮點數轉換導致精度損失 — 錯誤，全是整數運算

## 相關知識
- Composition 可包含多個 PrimitiveSegment
- 每個 segment 有 delay（播放前延遲）和 duration（播放時間）
- 總時間 = Σ(delay + duration)

## 難度說明
**Hard** - 需要理解 Composition 的結構和計算邏輯，並找出迴圈範圍錯誤。
