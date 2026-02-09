# CTS Display Hard Q003 - VirtualDisplay RequestedRefreshRate 問題

## 問題描述

你正在除錯一個 Android 14 系統的 Display 子系統問題。有開發者回報，當使用 VirtualDisplay API 並設置 `requestedRefreshRate` 時，創建的 VirtualDisplay 無法正確反映所請求的刷新率。

### 症狀

運行 CTS 測試時，以下測試失敗：

```
android.display.cts.VirtualDisplayTest#testVirtualDisplayWithRequestedRefreshRate
```

### 錯誤訊息

```
java.lang.AssertionError: expected:<30.0> but was:<60.0>
	at android.display.cts.VirtualDisplayTest.testVirtualDisplayWithRequestedRefreshRate(VirtualDisplayTest.java:331)
```

### 測試代碼片段

```java
private static final float REQUESTED_REFRESH_RATE = 30.0f;

@Test
public void testVirtualDisplayWithRequestedRefreshRate() throws Exception {
    VirtualDisplayConfig config = new VirtualDisplayConfig.Builder(NAME, WIDTH, HEIGHT, DENSITY)
            .setSurface(mSurface)
            .setRequestedRefreshRate(REQUESTED_REFRESH_RATE)
            .build();
    VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(config);
    assertNotNull("virtual display must not be null", virtualDisplay);
    Display display = virtualDisplay.getDisplay();
    try {
        assertDisplayRegistered(display, Display.FLAG_PRIVATE);
        assertEquals(mSurface, virtualDisplay.getSurface());

        // 這行斷言失敗
        assertEquals(display.getRefreshRate(), REQUESTED_REFRESH_RATE, 0.1f);
    } finally {
        virtualDisplay.release();
    }
    assertDisplayUnregistered(display);
}
```

### 你的任務

1. 找到導致 VirtualDisplay 無法正確設置 requestedRefreshRate 的 bug
2. 追蹤 refreshRate 從 API 層到 Display 層的完整傳遞路徑
3. 確定問題發生在哪個環節

### 提示

- `VirtualDisplayConfig` 儲存應用程式請求的配置
- `VirtualDisplayAdapter` 負責創建和管理虛擬顯示設備
- `DisplayDeviceInfo` 儲存設備層級的顯示資訊
- `Display.getRefreshRate()` 最終從 `DisplayInfo.renderFrameRate` 獲取值

### 相關檔案

重點檢查以下檔案：
- `frameworks/base/core/java/android/hardware/display/VirtualDisplayConfig.java`
- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`
- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`

## 時間限制

建議在 40 分鐘內完成
