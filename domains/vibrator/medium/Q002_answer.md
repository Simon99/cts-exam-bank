# Q002 Answer: CreateOneShot Accepts Invalid Amplitude

## 正確答案
**B**

## 問題根因
在 `VibrationEffect.java` 的 `createOneShot()` 方法中，
振幅驗證邏輯使用了錯誤的下界檢查。使用 `amplitude < 0` 而非 `amplitude <= 0`，
導致 amplitude = 0 未被拒絕。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public static VibrationEffect createOneShot(long milliseconds, int amplitude) {
    if (amplitude < 0 && amplitude != DEFAULT_AMPLITUDE) {  // BUG: < 應該是 <=
        throw new IllegalArgumentException("Invalid amplitude: " + amplitude);
    }
    if (amplitude > 255) {
        throw new IllegalArgumentException("Amplitude exceeds max: " + amplitude);
    }
    return new OneShot(milliseconds, amplitude);
}

// 正確的代碼
public static VibrationEffect createOneShot(long milliseconds, int amplitude) {
    if (amplitude <= 0 && amplitude != DEFAULT_AMPLITUDE) {
        throw new IllegalArgumentException("Invalid amplitude: " + amplitude);
    }
    // ...
}
```

## 選項分析
- **A** DEFAULT_AMPLITUDE 常數定義錯誤 — 錯誤，-1 是正確的
- **B** 下界檢查使用 < 而非 <= — ✅ 正確，0 未被排除
- **C** 上界 255 檢查缺失 — 錯誤，上界檢查是存在的
- **D** 驗證邏輯被跳過 — 錯誤，有執行只是條件錯誤

## 相關知識
- 振幅有效值：1-255 或 DEFAULT_AMPLITUDE (-1)
- 0 是無效的振幅，表示「不振動」但這不是合法輸入
- DEFAULT_AMPLITUDE 讓系統決定振幅

## 難度說明
**Medium** - 需要理解振幅的有效範圍，並分析邊界檢查的條件邏輯。
