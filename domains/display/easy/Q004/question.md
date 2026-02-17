# CTS 除錯練習題 DIS-E004

## 題目資訊
- **難度**: Easy
- **預估時間**: 15 分鐘
- **領域**: Display / Brightness

## 失敗的 CTS 測試

```
android.hardware.display.cts.BrightnessTest#testGetDefaultCurve
```

### 測試輸出

```
java.lang.NullPointerException: Attempt to invoke interface method 
'android.hardware.display.BrightnessConfiguration 
com.android.server.display.DisplayPowerControllerInterface.getDefaultBrightnessConfiguration()' 
on a null object reference
    at com.android.server.display.DisplayManagerService$BinderService.getDefaultBrightnessConfiguration(DisplayManagerService.java:4205)
    at android.hardware.display.IDisplayManager$Stub.onTransact(IDisplayManager.java:1247)
    at android.os.Binder.execTransactInternal(Binder.java:1344)
    at android.os.Binder.execTransact(Binder.java:1275)
```

### 測試代碼參考

```java
@Test
public void testGetDefaultCurve() {
    assumeTrue(numberOfSystemAppsWithPermission(
            Manifest.permission.CONFIGURE_DISPLAY_BRIGHTNESS) > 0);
    grantPermission(Manifest.permission.CONFIGURE_DISPLAY_BRIGHTNESS);

    BrightnessConfiguration defaultConfig = mDisplayManager.getDefaultBrightnessConfiguration();
    assumeNotNull(defaultConfig);

    Pair<float[], float[]> curve = defaultConfig.getCurve();
    assertTrue(curve.first.length > 0);
    assertEquals(curve.first.length, curve.second.length);
    // ... 更多驗證
}
```

## 問題描述

系統嘗試獲取預設的亮度配置曲線（brightness curve）時發生了 NullPointerException。

`getDefaultBrightnessConfiguration()` 是一個 Binder 服務方法，應該返回系統預設的亮度自動調整曲線配置。

## 需要檢查的檔案

```
frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
```

## 提示

1. 這是一個 Binder 服務調用，看看方法是如何取得 DisplayPowerController 的
2. `Display.DEFAULT_DISPLAY` 的值是什麼？
3. 為什麼 `mDisplayPowerControllers.get()` 會返回 null？

## 任務

1. 找出導致 NullPointerException 的根本原因
2. 說明為什麼取得的 controller 是 null
3. 提供修復方案
