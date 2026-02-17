# Q004 Answer: VibrationEffect Validate Waveform Timing Error

## 正確答案
**D**

## 問題根因
在 `VibrationEffect.Waveform` 的 `validate()` 方法中，
時間值驗證使用了 `timing > 0` 的條件來判斷有效，
但這會讓 timing = 0 也被視為無效，而實際應該用 `timing >= 0`。
然而問題是驗證被跳過了——使用 `continue` 而非 `throw`。

## Bug 位置
`frameworks/base/core/java/android/os/VibrationEffect.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public void validate() {
    for (int i = 0; i < mTimings.length; i++) {
        if (mTimings[i] < 0) {
            continue;  // BUG: 跳過而非拋出異常
        }
        // 其他驗證...
    }
}

// 正確的代碼
public void validate() {
    for (int i = 0; i < mTimings.length; i++) {
        if (mTimings[i] < 0) {
            throw new IllegalArgumentException("Timing values must be non-negative");
        }
        // 其他驗證...
    }
}
```

## 選項分析
- **A** 驗證方法從未被呼叫 — 錯誤，有呼叫但邏輯錯誤
- **B** 負數被轉換為絕對值 — 錯誤，沒有這個操作
- **C** 只驗證第一個時間值 — 錯誤，有迴圈遍歷
- **D** 發現無效值時使用 continue 而非 throw — ✅ 正確

## 相關知識
- validate() 用於確保 VibrationEffect 符合規範
- 所有時間值必須 >= 0（可以是 0 表示暫停）
- 無效效果不應該被發送到振動器服務

## 難度說明
**Hard** - 需要追蹤驗證流程，理解 continue 和 throw 的行為差異。
