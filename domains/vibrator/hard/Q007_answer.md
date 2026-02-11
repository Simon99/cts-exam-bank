# Q007 Answer: Waveform Repeat Index Boundary Validation

## 正確答案
**B**

## 問題根因
在 `VibrationEffect.java` 的 `createWaveform` 方法中，
repeat 的上界檢查使用了 `>` 而非 `>=`，
允許 repeat 等於 timings.length，而這是無效的索引。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public static VibrationEffect createWaveform(long[] timings, int[] amplitudes, int repeat) {
    // ...
    // BUG: > 允許 repeat == timings.length
    if (repeat < -1 || repeat > timings.length) {
        throw new IllegalArgumentException("repeat index out of bounds");
    }
    // ...
}

// 正確的代碼
public static VibrationEffect createWaveform(long[] timings, int[] amplitudes, int repeat) {
    // ...
    if (repeat < -1 || repeat >= timings.length) {
        throw new IllegalArgumentException("repeat index out of bounds");
    }
    // ...
}
```

## 選項分析
- **A** repeat=-1 的特殊處理被移除 — 錯誤，-1 仍有效
- **B** 上界使用 > 而非 >= 檢查 — ✅ 正確
- **C** 先檢查長度再驗證 repeat — 錯誤，順序不影響結果
- **D** repeat 與 amplitudes.length 比較 — 錯誤，應與 timings 比較

## 相關知識
- repeat=-1：不重複，播放一次後結束
- repeat=0：從索引 0 開始無限重複
- repeat=N：從索引 N 開始無限重複
- 有效範圍：-1 <= repeat < timings.length

## 難度說明
**Hard** - 需要理解 repeat 參數語義和邊界條件，經典的 off-by-one 錯誤。
