# CTS 面試題：VirtualDisplay FLAG 處理邏輯問題

## 問題描述

以下 CTS 測試失敗了：

```
android.display.cts.VirtualDisplayTest#testUntrustedSysDecorVirtualDisplay
```

### 失敗訊息
```
java.lang.AssertionError: 
Expected Display flags: FLAG_PRIVATE (0x4)
Actual Display flags: FLAG_PRIVATE | FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS (0x84)
    at org.junit.Assert.assertEquals(Assert.java:115)
    at android.display.cts.VirtualDisplayTest.assertDisplayRegistered(VirtualDisplayTest.java:xxx)
    at android.display.cts.VirtualDisplayTest.testUntrustedSysDecorVirtualDisplay(VirtualDisplayTest.java:xxx)
```

測試程式碼：
```java
@Test
public void testUntrustedSysDecorVirtualDisplay() throws Exception {
    VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(NAME,
            WIDTH, HEIGHT, DENSITY, mSurface,
            VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS);
    assertNotNull("virtual display must not be null", virtualDisplay);

    Display display = virtualDisplay.getDisplay();
    try {
        // Verify that the created virtual display doesn't have flags
        // FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS.
        assertDisplayRegistered(display, Display.FLAG_PRIVATE);  // ← 這裡失敗
        // ...
    } finally {
        virtualDisplay.release();
    }
}
```

### 觀察到的行為
- 創建 VirtualDisplay 時傳入 `VIRTUAL_DISPLAY_FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS`
- 但沒有傳入 `VIRTUAL_DISPLAY_FLAG_TRUSTED`
- 預期：FLAG_SHOULD_SHOW_SYSTEM_DECORATIONS 應該被清除（安全原因）
- 實際：該 flag 沒有被清除

### 相關檔案
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 你的任務

1. 找出 bug 的根本原因
2. 提供修復方案
3. 解釋為什麼不受信任的 VirtualDisplay 不能顯示系統裝飾

## 提示

- 思考 `createVirtualDisplayInternal()` 中的 flag 處理邏輯
- 為什麼 TRUSTED flag 和 SHOULD_SHOW_SYSTEM_DECORATIONS flag 有關聯？
- 什麼樣的條件錯誤會導致「不該保留的 flag 反而被保留」？
