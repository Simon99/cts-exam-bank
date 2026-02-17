# Q003 Answer: MotionPredictor predict() 時間計算錯誤

## 正確答案
**A) `predict()` 中的時間差沒有從 milliseconds 轉換為 seconds**

## 問題根因
在 `MotionPredictor.java` 的 `predict()` 函數中，
時間差以毫秒為單位但直接乘以 pixels/second 的速度，缺少除以 1000 的轉換。

## Bug 位置
`frameworks/base/core/java/android/view/MotionPredictor.java`

## 修復方式
```java
// 錯誤的代碼
public MotionEvent predict(long targetTimeMs) {
    long deltaTime = targetTimeMs - currentTimeMs;  // 16ms
    // BUG: deltaTime 是 ms，velocity 是 pixels/second
    float predictedX = currentX + velocityX * deltaTime;  // 100 + 1000 * 16 = 16100
}

// 正確的代碼
public MotionEvent predict(long targetTimeMs) {
    long deltaTimeMs = targetTimeMs - currentTimeMs;  // 16ms
    float deltaTimeSec = deltaTimeMs / 1000.0f;  // 0.016 seconds
    float predictedX = currentX + velocityX * deltaTimeSec;  // 100 + 1000 * 0.016 = 116
}
```

## 為什麼其他選項不對

**B)** 使用 targetTime (1016ms) 會得到 100 + 1000 * 1016 = 1016100，更離譜。

**C)** 速度是 pixels/second，這是正確的。問題是時間沒轉換。

**D)** 順序錯誤會得到負的 deltaTime (-16)，結果會是 100 - 16000 = -15900。

## 相關知識
- 動作預測用於減少觸控延遲
- 時間單位一致性是物理計算的關鍵
- Android 時間戳通常以 nanoseconds 或 milliseconds 為單位

## 難度說明
**Hard** - 需要分析數值差異（約 1000 倍）並理解單位轉換問題。
