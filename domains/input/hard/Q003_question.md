# Q003: MotionPredictor predict() 時間計算錯誤

## CTS Test
`android.view.cts.MotionPredictorTest#testPredict`

## Failure Log
```
junit.framework.AssertionFailedError: predict() returned wrong position
Current time: 1000ms, Target time: 1016ms (16ms ahead)
Current position: (100.0, 100.0)
Current velocity: (1000.0, 0.0) pixels/second

Expected predicted X: ~116.0 (100 + 1000 * 0.016)
Actual predicted X: 1100.0

at android.view.cts.MotionPredictorTest.testPredict(MotionPredictorTest.java:78)
```

## 現象描述
CTS 測試報告 `MotionPredictor.predict(targetTime)` 預測位置錯誤。
目標時間是 16ms 後，速度是 1000 pixels/second，應該移動 16 pixels。
但實際預測值比預期大約 1000 倍。

## 提示
- 預測公式：`predictedX = currentX + velocityX * deltaTime`
- deltaTime = targetTime - currentTime
- 問題可能在於時間單位轉換

## 選項

A) `predict()` 中的時間差沒有從 milliseconds 轉換為 seconds

B) `predict()` 中使用 targetTime 而非 deltaTime 做計算

C) `predict()` 中速度單位假設錯誤（pixels/ms vs pixels/s）

D) `predict()` 中時間差計算順序錯誤（currentTime - targetTime）
