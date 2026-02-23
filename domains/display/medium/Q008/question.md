# CTS 題目：LogicalDisplay.updateLocked 寬高互換 Bug

## 題目類型
- 難度：Medium
- 領域：Display
- 測試方法：`android.display.cts.DisplayTest#testGetMetrics`

## 情境描述

CTS 測試 `DisplayTest#testGetMetrics` 失敗，測試報告顯示：

```
junit.framework.AssertionFailedError: 
Secondary display width is unexpected; height: 161 name Overlay #1 id 2 type 4
expected:<181> but was:<161>
```

測試創建了一個 181x161 的 overlay display，但 `getMetrics()` 回傳的 `widthPixels` 卻是 161（與 height 相同）。

## 測試程式碼片段

```java
@Test
public void testGetMetrics(DisplayManager manager) {
    Display display = getSecondaryDisplay(manager.getDisplays());

    DisplayMetrics outMetrics = new DisplayMetrics();
    display.getMetrics(outMetrics);

    assertEquals("Secondary display width is unexpected; height: " + outMetrics.heightPixels
            + " name " + display.getName() + " id " + display.getDisplayId()
            + " type " + display.getType(), SECONDARY_DISPLAY_WIDTH, outMetrics.widthPixels);
    assertEquals(SECONDARY_DISPLAY_HEIGHT, outMetrics.heightPixels);
}
```

## 問題

Bug 位於 `LogicalDisplay.java` 的 `updateLocked()` 方法中。請檢查以下程式碼，找出導致 width 和 height 數值錯誤的原因：

```java
public void updateLocked(DisplayDeviceRepository deviceRepo) {
    // ... 省略前面程式碼 ...
    int maskedWidth = deviceInfo.width - maskingInsets.left - maskingInsets.right;
    int maskedHeight = deviceInfo.height - maskingInsets.top - maskingInsets.bottom;

    mBaseDisplayInfo.type = deviceInfo.type;
    mBaseDisplayInfo.address = deviceInfo.address;
    mBaseDisplayInfo.deviceProductInfo = deviceInfo.deviceProductInfo;
    mBaseDisplayInfo.name = deviceInfo.name;
    mBaseDisplayInfo.uniqueId = deviceInfo.uniqueId;
    mBaseDisplayInfo.appWidth = maskedHeight;
    mBaseDisplayInfo.appHeight = maskedWidth;
    mBaseDisplayInfo.logicalWidth = maskedWidth;
    mBaseDisplayInfo.logicalHeight = maskedHeight;
    // ... 省略後面程式碼 ...
}
```

## 選項

**A.** `logicalWidth` 和 `logicalHeight` 的賦值順序錯誤

**B.** `appWidth` 被賦值為 `maskedHeight`，`appHeight` 被賦值為 `maskedWidth`，導致寬高互換

**C.** `maskedWidth` 和 `maskedHeight` 的計算公式錯誤

**D.** `deviceInfo.width` 和 `deviceInfo.height` 本身就是錯誤的

## 正確答案

B
