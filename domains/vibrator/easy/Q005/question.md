# Q005: Predefined Effect Creation Failed

## CTS Test
`android.os.cts.VibrationEffectTest#testCreatePredefined`

## Failure Log
```
java.lang.IllegalArgumentException: Unknown prebaked effect type (value=0)
    at android.os.vibrator.PrebakedSegment.validate(PrebakedSegment.java:181)
    at android.os.VibrationEffect.createPredefined(VibrationEffect.java:315)
    at android.os.cts.VibrationEffectTest.testCreatePredefined(VibrationEffectTest.java:156)
```

## 現象描述
呼叫 `VibrationEffect.createPredefined(EFFECT_CLICK)` 時拋出 IllegalArgumentException。
EFFECT_CLICK 的值是 0，但系統報告這是未知的效果類型。

## 提示
- 檢查效果 ID 的驗證邏輯
- 追蹤 `validate()` 方法的 switch-case 結構
- EFFECT_CLICK = 0 是第一個預定義效果
