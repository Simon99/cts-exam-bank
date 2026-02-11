# Q009: KeyEvent hasModifiers() 位元運算錯誤

## CTS Test
`android.view.cts.AppKeyCombinationsTest#testHasModifiers`

## Failure Log
```
junit.framework.AssertionFailedError: hasModifiers() returns wrong result for complex modifier combinations
Test cases:
  MetaState = META_CTRL_ON | META_SHIFT_ON | META_ALT_ON (0x00001003)

  Test 1: hasModifiers(META_CTRL_ON | META_SHIFT_ON)  // 0x00001001
    Expected: true (CTRL+SHIFT are both present)
    Actual: false

  Test 2: hasModifiers(META_CTRL_ON)  // 0x00001000
    Expected: true (CTRL is present)
    Actual: true (correct)

  Test 3: hasModifiers(META_CTRL_ON | META_SHIFT_ON | META_ALT_ON)  // 0x00001003
    Expected: true (exact match)
    Actual: true (correct)

Pattern: Single modifier works, exact match works, but subset fails!

at android.view.cts.AppKeyCombinationsTest.testHasModifiers(AppKeyCombinationsTest.java:234)
```

## 現象描述
CTS 測試發現 `KeyEvent.hasModifiers(int modifiers)` 在檢查修飾鍵子集時返回錯誤結果。只有完全匹配或單一修飾鍵時才正確。

## 提示
- `hasModifiers()` 應該檢查「所有指定的修飾鍵都被按下」
- 正確的位元運算：`(metaState & modifiers) == modifiers`
- 錯誤的運算可能：`metaState == modifiers` 或其他變體

## 選項

A) `hasModifiers()` 使用 `==` 比較而非位元 AND，要求完全匹配

B) `hasModifiers()` 使用 `(metaState & modifiers) != 0`，只檢查是否有任一修飾鍵

C) `hasModifiers()` 使用 `(metaState | modifiers) == modifiers`，邏輯顛倒

D) `hasModifiers()` 先正規化 metaState 但參數 modifiers 未正規化，導致比較失敗
