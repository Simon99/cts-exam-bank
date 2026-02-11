# CTS 面試題目 DIS-E005

## 題目資訊
- **難度**: Easy
- **領域**: Display (Virtual Display)
- **預計時間**: 15 分鐘

## 情境描述

你是 Android Framework Display 團隊的一員。QA 團隊回報以下 CTS 測試失敗：

```
android.hardware.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay
```

錯誤訊息：
```
junit.framework.AssertionFailedError: Virtual display initial state incorrect
Expected: STATE_UNKNOWN (0)
Actual: STATE_OFF (1)
```

## 失敗的測試

測試檢查新建立的 private virtual display 初始狀態是否正確：

```java
public void testPrivateVirtualDisplay() throws Exception {
    VirtualDisplay virtualDisplay = mDisplayManager.createVirtualDisplay(
            NAME, WIDTH, HEIGHT, DENSITY, null /* surface */,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_PRESENTATION);
    assertNotNull(virtualDisplay);
    
    Display display = virtualDisplay.getDisplay();
    // 驗證初始狀態
    assertEquals(Display.STATE_UNKNOWN, display.getState());
    // ... 其他驗證 ...
}
```

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/VirtualDisplayAdapter.java`

## 任務

1. 找出導致 CTS 測試失敗的 bug
2. 解釋為什麼這個 bug 會造成測試失敗
3. 提供修復方案

## 提示

- 關注 VirtualDisplayDevice 的初始化邏輯
- 注意 `mDisplayState` 的初始值設定
- 思考 `Display.STATE_UNKNOWN` 與 `Display.STATE_OFF` 的差異

## 評分標準

| 項目 | 分數 |
|------|------|
| 正確定位 bug 位置 | 40% |
| 解釋 bug 原因 | 30% |
| 提供正確修復 | 30% |
