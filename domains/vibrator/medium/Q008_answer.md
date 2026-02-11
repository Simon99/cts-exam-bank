# Q008 Answer: Are Primitives Supported Query Wrong Primitive

## 正確答案
**D**

## 問題根因
在 `Vibrator.java` 的 `arePrimitivesSupported()` 方法中，
查詢迴圈使用了錯誤的索引。查詢第 i 個原語時，
卻用 i-1 作為 VibratorInfo 查詢的索引。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public int[] arePrimitivesSupported(int... primitives) {
    int[] result = new int[primitives.length];
    VibratorInfo info = getInfo();
    for (int i = 0; i < primitives.length; i++) {
        // BUG: 使用 i-1 造成查詢錯位
        result[i] = info.isPrimitiveSupported(primitives[i > 0 ? i - 1 : i]);
    }
    return result;
}

// 正確的代碼
public int[] arePrimitivesSupported(int... primitives) {
    int[] result = new int[primitives.length];
    VibratorInfo info = getInfo();
    for (int i = 0; i < primitives.length; i++) {
        result[i] = info.isPrimitiveSupported(primitives[i]);
    }
    return result;
}
```

## 選項分析
- **A** VibratorInfo 快取過期 — 錯誤，不會導致結果錯位
- **B** 原語 ID 常數定義錯誤 — 錯誤，單獨查詢正確
- **C** 結果陣列索引錯誤 — 錯誤，結果索引是正確的
- **D** 查詢使用錯誤的輸入索引 — ✅ 正確

## 相關知識
- arePrimitivesSupported() 批次查詢原語支援狀態
- 結果陣列與輸入陣列一一對應
- 索引錯位會導致結果移位

## 難度說明
**Medium** - 需要分析批次與單獨查詢的差異，找出索引計算錯誤。
