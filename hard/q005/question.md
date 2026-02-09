# Q005: Display Mode Comparison Logic Error

## 題目背景

你收到了一個 CTS 測試失敗的 bug report：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay

java.lang.AssertionError: 
    at org.junit.Assert.assertTrue(Assert.java:42)
    at android.display.cts.DisplayTest.testActiveModeIsSupportedModesOnDefaultDisplay(DisplayTest.java:xxx)
```

使用者反映：測試顯示器的當前模式（active mode）是否在支援的模式列表中，但這個基本檢查卻失敗了。

## 錯誤描述

`Display.getMode()` 返回的當前顯示模式應該存在於 `Display.getSupportedModes()` 返回的支援模式列表中。測試使用 `equals()` 方法比較這兩者，但比較結果始終為 false，導致測試失敗。

## 測試代碼

```java
@Test
public void testActiveModeIsSupportedModesOnDefaultDisplay() {
    Display.Mode[] supportedModes = mDefaultDisplay.getSupportedModes();
    Display.Mode activeMode = mDefaultDisplay.getMode();
    boolean activeModeIsSupported = false;
    for (Display.Mode mode : supportedModes) {
        if (mode.equals(activeMode)) {
            activeModeIsSupported = true;
            break;
        }
    }
    assertTrue(activeModeIsSupported);
}
```

## 預期行為

- `getMode()` 返回的當前模式應該能在 `getSupportedModes()` 中找到匹配項
- `Display.Mode.equals()` 對於相同的顯示模式應該返回 `true`

## 實際行為

- `equals()` 對於所有模式都返回 `false`，即使是同一個模式實例
- 導致 `activeModeIsSupported` 保持 `false`，測試失敗

## 驗證測試

```bash
atest android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay
```

## 提示

1. 問題出在客戶端的 `Display.Mode` 類
2. 檢查 `equals()` 方法的實現
3. 思考：什麼樣的運算符錯誤會導致「相等的對象反而不相等」？
4. 注意 `&&` 運算符的短路求值特性

## 難度

**Hard** - 需要理解 Java `equals()` 方法的正確實現模式，以及比較運算符錯誤如何影響邏輯判斷
