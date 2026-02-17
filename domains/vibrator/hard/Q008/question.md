# Q008: Composition Primitive Scale Boundary Validation

## CTS Test
`android.os.cts.VibrationEffectTest#testCompositionPrimitiveScaleBounds`

## Failure Log
```
junit.framework.AssertionFailedError: addPrimitive should reject scale > 1.0
VibrationEffect.startComposition()
    .addPrimitive(VibrationEffect.Composition.PRIMITIVE_CLICK, 1.5f)
    .compose()
did not throw IllegalArgumentException

Scale must be in range [0.0, 1.0]

at android.os.cts.VibrationEffectTest.testCompositionPrimitiveScaleBounds(VibrationEffectTest.java:412)
```

## 現象描述
呼叫 `addPrimitive(primitiveId, scale)` 時，
scale 傳入 1.5f，應該拋出 IllegalArgumentException 表示超出範圍，
但方法接受了這個無效值。

## 提示
- 檢查 scale 參數的範圍驗證
- scale 應該在 0.0 到 1.0 之間
- 考慮邊界條件的判斷方式
