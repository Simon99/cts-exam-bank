# Q003: Composition Compose Empty State Error

## CTS Test
`android.os.cts.VibrationEffectTest#testCompositionComposeEmptyThrows`

## Failure Log
```
junit.framework.AssertionFailedError: compose() on empty composition should throw
VibrationEffect.startComposition().compose() did not throw IllegalStateException
Empty composition is invalid

at android.os.cts.VibrationEffectTest.testCompositionComposeEmptyThrows(VibrationEffectTest.java:425)
```

## 現象描述
呼叫 `startComposition().compose()` 建立空的 Composition，
應該拋出 IllegalStateException，但沒有。
空的 Composition 是無效的振動效果。

## 提示
- 檢查 compose() 的狀態驗證
- 注意對空內容的檢查
- 可能驗證條件被反轉
