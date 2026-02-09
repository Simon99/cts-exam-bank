# Q009: Display Mode 相等性比較錯誤

## 題目背景

你收到了一個 CTS 測試失敗的 bug report：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay

java.lang.AssertionError: expected to be true
    at org.junit.Assert.assertTrue(Assert.java:42)
    at android.display.cts.DisplayTest.testActiveModeIsSupportedModesOnDefaultDisplay(DisplayTest.java:942)
```

## 錯誤描述

測試檢查 `getMode()` 返回的當前顯示模式是否存在於 `getSupportedModes()` 返回的支援模式列表中。測試使用 `equals()` 方法比較兩個 `Display.Mode` 對象，但比較結果始終為 `false`，即使兩個 Mode 應該相等。

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
- 當兩個 Mode 有相同的 `mModeId`、尺寸、刷新率等屬性時，`equals()` 應該返回 `true`

## 實際行為

- `equals()` 對於相同屬性的 Mode 對象也返回 `false`
- 導致 `activeModeIsSupported` 保持 `false`，測試失敗

## 驗證測試

```bash
atest android.display.cts.DisplayTest#testActiveModeIsSupportedModesOnDefaultDisplay
```

## 提示

1. 問題出在 `Display.Mode` 類的 `equals()` 方法
2. 檢查比較邏輯中使用的運算符
3. 思考：在一個由 `&&` 連接的多條件表達式中，如果其中一個條件永遠為 `false`，結果會是什麼？
4. 注意 `==` 和 `!=` 在數值比較中的區別

## 相關檔案

- `frameworks/base/core/java/android/view/Display.java`

## 難度

**Medium** - 需要理解 Java equals() 方法的比較邏輯和布林運算
