# Q001 Answer: Waveform Amplitudes Array Length Mismatch

## 正確答案
**C**

## 問題根因
在 `VibrationEffect.java` 的 `createWaveform(long[], int[], int)` 方法中，
長度檢查使用了 `>=` 而非 `!=`，只檢查 amplitudes 是否長於 timings，
但沒有檢查 amplitudes 短於 timings 的情況。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public static VibrationEffect createWaveform(long[] timings, int[] amplitudes, int repeat) {
    // BUG: >= 只檢查 amplitudes 太長，不檢查太短
    if (amplitudes.length >= timings.length) {
        throw new IllegalArgumentException("timings and amplitudes must have equal length");
    }
    // ...
}

// 正確的代碼
public static VibrationEffect createWaveform(long[] timings, int[] amplitudes, int repeat) {
    if (amplitudes.length != timings.length) {
        throw new IllegalArgumentException("timings and amplitudes must have equal length");
    }
    // ...
}
```

## 選項分析
- **A** timings 陣列驗證缺失 — 錯誤，問題在長度比較
- **B** repeat 參數影響驗證順序 — 錯誤，repeat 與長度無關
- **C** 使用 >= 而非 != 比較長度 — ✅ 正確
- **D** amplitudes 為 null 時跳過驗證 — 錯誤，null 會有 NPE

## 相關知識
- timings 和 amplitudes 必須一一對應
- 每個 timing 定義振動/暫停時間
- 每個 amplitude 定義對應時段的強度

## 難度說明
**Hard** - 需要理解兩個陣列的對應關係，並分析不對稱的邊界檢查錯誤。
