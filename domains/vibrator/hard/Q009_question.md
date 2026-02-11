# Q009: VibrationEffect Scale Factor Calculation Error

## CTS Test
`android.os.cts.VibrationEffectTest#testScaleEffect`

## Failure Log
```
junit.framework.AssertionFailedError: 
Expected scaled amplitude: 64
Actual scaled amplitude: 128

Original effect: createOneShot(100, 128)
Scale factor: 0.5f
Expected: amplitude * scaleFactor = 128 * 0.5 = 64
Got: 128

at android.os.cts.VibrationEffectTest.testScaleEffect(VibrationEffectTest.java:523)
```

## 現象描述
呼叫 `VibrationEffect.scale(0.5f)` 對一個 amplitude=128 的效果進行縮放，
預期得到 amplitude=64，但實際結果仍是 128。
縮放功能似乎沒有生效。

## 提示
- 檢查 scale() 方法的實現
- 考慮返回值是否被正確處理
- 注意 immutable 物件的處理方式
