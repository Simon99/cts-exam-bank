# Q006: Composition Add Primitive Scale Validation Failed

## CTS Test
`android.os.cts.VibrationEffectTest#testCompositionAddPrimitiveScale`

## Failure Log
```
junit.framework.AssertionFailedError: addPrimitive should reject scale > 1.0
VibrationEffect.startComposition()
    .addPrimitive(PRIMITIVE_CLICK, 1.5f)
    .compose() did not throw IllegalArgumentException

at android.os.cts.VibrationEffectTest.testCompositionAddPrimitiveScale(VibrationEffectTest.java:312)
```

## 現象描述
`Composition.addPrimitive(primitiveId, scale)` 應該驗證 scale 在 [0, 1.0] 範圍內。
但傳入 scale = 1.5 時未拋出例外。

## 提示
- 檢查 Composition.addPrimitive() 的 scale 驗證
- 注意上界 1.0 的檢查
- 可能只檢查了下界
