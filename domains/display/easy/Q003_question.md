# CTS 題目：DIS-E003

## 情境描述

你是 Android Framework 工程師，負責維護 DisplayManagerService。QA 團隊回報以下 CTS 測試失敗：

```
android.hardware.display.cts.BrightnessTest#testGetDefaultCurve
```

## 錯誤訊息

```
java.lang.NullPointerException: Attempt to invoke interface method 
'android.hardware.display.BrightnessConfiguration 
com.android.server.display.DisplayPowerControllerInterface.getDefaultBrightnessConfiguration()' 
on a null object reference
    at com.android.server.display.DisplayManagerService$BinderService.getDefaultBrightnessConfiguration(DisplayManagerService.java:4207)
    at android.hardware.display.IDisplayManager$Stub.onTransact(IDisplayManager.java:1832)
    ...
```

## 測試說明

`testGetDefaultCurve` 測試驗證系統能正確返回預設的亮度曲線配置（brightness curve）。測試通過呼叫 `DisplayManager.getDefaultBrightnessConfiguration()` 來獲取預設配置。

## 相關程式碼

請檢查以下檔案：
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

重點關注 `getDefaultBrightnessConfiguration()` 方法（約第 4201-4211 行）。

## 任務

1. 找出導致 NullPointerException 的 bug
2. 解釋為什麼這個 bug 會導致測試失敗
3. 提供修復方案

## 提示

- 注意 `mDisplayPowerControllers.get()` 的參數
- 檢查使用的 Display ID 常數是否正確
- `Display.DEFAULT_DISPLAY` 的值是 0
- `Display.INVALID_DISPLAY` 的值是 -1
