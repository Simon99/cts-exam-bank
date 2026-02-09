# Q006: Virtual Display Flags 設定問題

## 題目背景

你收到了一個 CTS 測試失敗的 bug report：

```
FAILURES!!!
Tests run: 1,  Failures: 1

android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay

java.lang.AssertionError: display must have correct flags expected:<17> but was:<1>
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.display.cts.VirtualDisplayTest.assertDisplayRegistered(VirtualDisplayTest.java:442)
    at android.display.cts.VirtualDisplayTest.testPrivatePresentationVirtualDisplay(VirtualDisplayTest.java:221)
```

## 錯誤描述

測試創建一個帶有 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 的 VirtualDisplay，驗證返回的 Display 物件的 flags。測試預期 flags 為 `FLAG_PRIVATE | FLAG_PRESENTATION`（值為 17），但實際只得到 `FLAG_PRIVATE`（值為 1）。

## 測試代碼

```java
@Test
public void testPrivatePresentationVirtualDisplay() throws Exception {
    VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(NAME,
            WIDTH, HEIGHT, DENSITY, mSurface,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_PRESENTATION);
    assertNotNull("virtual display must not be null", virtualDisplay);

    Display display = virtualDisplay.getDisplay();
    try {
        assertDisplayRegistered(display, Display.FLAG_PRIVATE | Display.FLAG_PRESENTATION);
        // ...
    } finally {
        virtualDisplay.release();
    }
}

private void assertDisplayRegistered(Display display, int flags) {
    // ...
    assertEquals("display must have correct flags", flags, display.getFlags());
    // ...
}
```

## 預期行為

- VirtualDisplay 創建時應該正確設置 `FLAG_PRESENTATION`
- `display.getFlags()` 應該返回 `FLAG_PRIVATE | FLAG_PRESENTATION = 17`

## 實際行為

- `FLAG_PRESENTATION` 沒有被正確設置
- `display.getFlags()` 只返回 `FLAG_PRIVATE = 1`

## 驗證測試

```bash
atest android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay
```

## 提示

1. 問題出在 VirtualDisplayAdapter.java
2. 檢查 flags 的設置邏輯
3. 思考：什麼樣的運算符錯誤會導致「flag 沒有被正確添加」？
4. 注意 `|=` 和 `&=` 運算符的區別

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

## 難度

**Medium** - 需要理解位元運算和 flag 設置邏輯
