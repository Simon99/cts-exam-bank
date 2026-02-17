# Q005: Are Effects Supported Returns Wrong Length

## CTS Test
`android.os.cts.VibrationEffectTest#testAreEffectsSupported`

## Failure Log
```
java.lang.ArrayIndexOutOfBoundsException: length=2; index=2
    at android.os.cts.VibrationEffectTest.testAreEffectsSupported(VibrationEffectTest.java:267)

Test called: areEffectsSupported(EFFECT_CLICK, EFFECT_TICK, EFFECT_HEAVY_CLICK)
Expected result array length: 3
Actual result array length: 2
```

## 現象描述
呼叫 `areEffectsSupported()` 傳入 3 個效果 ID，但回傳的陣列只有 2 個元素。
測試嘗試存取第 3 個元素時發生 ArrayIndexOutOfBoundsException。

## 提示
- 檢查 areEffectsSupported() 的陣列建立邏輯
- 注意結果陣列的大小計算
- 可能存在 off-by-one 錯誤
