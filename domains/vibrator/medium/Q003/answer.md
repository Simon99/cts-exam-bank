# Q003 Answer: Waveform Repeat Index Validation Failed

## 正確答案
**D**

## 問題根因
在 `VibrationEffect.java` 的 `createWaveform()` 方法中，
只檢查了 repeatIndex 的下界（>= -1），但遺漏了上界檢查（< timings.length）。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public static VibrationEffect createWaveform(long[] timings, int repeat) {
    if (repeat < -1) {  // BUG: 缺少上界檢查
        throw new IllegalArgumentException("Invalid repeat index: " + repeat);
    }
    return new Waveform(timings, null, repeat);
}

// 正確的代碼
public static VibrationEffect createWaveform(long[] timings, int repeat) {
    if (repeat < -1 || repeat >= timings.length) {
        throw new IllegalArgumentException("Invalid repeat index: " + repeat);
    }
    return new Waveform(timings, null, repeat);
}
```

## 選項分析
- **A** timings 陣列未正確複製 — 錯誤，不影響 index 驗證
- **B** repeat = -1 的特殊處理錯誤 — 錯誤，-1（不重複）的處理是正確的
- **C** 驗證發生在 Waveform 建構函數內 — 錯誤，建構函數也沒有驗證
- **D** 缺少 repeatIndex 上界檢查 — ✅ 正確

## 相關知識
- repeatIndex = -1 表示不重複（播放一次）
- repeatIndex >= 0 表示從該索引開始循環
- 索引必須在 [0, timings.length-1] 範圍內

## 難度說明
**Medium** - 需要理解 repeatIndex 的完整有效範圍，並找到遺漏的邊界檢查。
