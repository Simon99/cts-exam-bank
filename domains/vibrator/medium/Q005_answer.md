# Q005 Answer: Are Effects Supported Returns Wrong Length

## 正確答案
**C**

## 問題根因
在 `Vibrator.java` 的 `areEffectsSupported()` 方法中，
結果陣列的大小使用 `effects.length - 1` 而非 `effects.length`，
導致少建立一個元素。

## Bug 位置
`frameworks/base/core/java/android/os/Vibrator.java`

## 錯誤代碼 vs 正確代碼
```java
// 錯誤的代碼
public int[] areEffectsSupported(int... effects) {
    int[] result = new int[effects.length - 1];  // BUG: 少一個元素
    for (int i = 0; i < effects.length; i++) {
        result[i] = isEffectSupported(effects[i]);  // 會越界
    }
    return result;
}

// 正確的代碼
public int[] areEffectsSupported(int... effects) {
    int[] result = new int[effects.length];
    for (int i = 0; i < effects.length; i++) {
        result[i] = isEffectSupported(effects[i]);
    }
    return result;
}
```

## 選項分析
- **A** 輸入陣列被錯誤過濾 — 錯誤，輸入正常
- **B** 迴圈條件使用 < 而非 <= — 錯誤，< 是正確的
- **C** 結果陣列大小少算一個 — ✅ 正確
- **D** varargs 參數轉換錯誤 — 錯誤，varargs 轉換是正確的

## 相關知識
- areEffectsSupported() 批次查詢多個效果的支援狀態
- 回傳陣列的每個元素對應輸入的效果 ID
- 常見的 off-by-one 錯誤模式

## 難度說明
**Medium** - 需要分析陣列大小的計算和迴圈的邊界關係。
