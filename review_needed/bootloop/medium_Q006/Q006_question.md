# CTS 面試題：Display 權限存取邏輯問題

## 問題描述

以下 CTS 測試失敗了：

```
android.display.cts.DisplayTest#testGetDisplays
```

### 失敗訊息
```
java.lang.AssertionError: expected to be true
    at org.junit.Assert.assertTrue(Assert.java:42)
    at android.display.cts.DisplayTest.testGetDisplays(DisplayTest.java:xxx)
```

測試程式碼：
```java
@Test
public void testGetDisplays() {
    Display[] displays = mDisplayManager.getDisplays();
    assertNotNull(displays);
    assertTrue(2 <= displays.length);
    boolean hasDefaultDisplay = false;
    boolean hasSecondaryDisplay = false;
    for (Display display : displays) {
        if (display.getDisplayId() == DEFAULT_DISPLAY) {
            hasDefaultDisplay = true;
        }
        if (isSecondaryDisplay(display)) {
            hasSecondaryDisplay = true;
        }
    }
    assertTrue(hasDefaultDisplay);  // ← 這裡失敗
    assertTrue(hasSecondaryDisplay);
}
```

### 觀察到的行為
- `mDisplayManager.getDisplays()` 返回的陣列不包含 DEFAULT_DISPLAY (displayId=0)
- 應用程式應該有權限訪問預設顯示器，但 getDisplays() 沒有返回它

### 相關檔案
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplayMapper.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 你的任務

1. 找出 bug 的根本原因
2. 提供修復方案
3. 解釋為什麼這個 bug 會導致測試失敗

## 提示

- 思考 `DisplayManager.getDisplays()` 如何過濾顯示器
- 權限檢查的邏輯是什麼？
- 什麼樣的邏輯錯誤會導致「有權限的顯示器反而不被返回」？
