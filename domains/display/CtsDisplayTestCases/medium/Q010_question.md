# Hard Q003: Virtual Display Presentation Flag 遺漏

## 問題描述

您正在調試一個 Android 系統問題。當應用程式創建一個帶有 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 標誌的虛擬顯示時，該顯示沒有被正確識別為 presentation display。

## CTS 測試結果

```
adb shell am instrument -w -r -e class android.display.cts.VirtualDisplayTest#testPrivatePresentationVirtualDisplay android.display.cts/androidx.test.runner.AndroidJUnitRunner
```

測試失敗，錯誤訊息：
```
junit.framework.AssertionFailedError: display must have correct flags expected:<17> but was:<1>
```

## 技術背景

Virtual Display 系統允許應用程式創建虛擬顯示器用於各種用途：
- 私有顯示：僅對創建者可見
- Presentation 顯示：用於投影/簡報場景
- 公開顯示：對所有應用程式可見

當創建虛擬顯示時，應用程式可以指定多個標誌來控制顯示的行為。系統需要正確地將這些標誌轉換為 DisplayDeviceInfo 中的對應標誌。

## 相關元件

- `DisplayManager.createVirtualDisplay()` - 應用程式 API
- `VirtualDisplayAdapter` - 處理虛擬顯示創建
- `DisplayDeviceInfo` - 包含顯示設備的詳細資訊和標誌

## 任務

找出為什麼 `VIRTUAL_DISPLAY_FLAG_PRESENTATION` 沒有被正確轉換為 `Display.FLAG_PRESENTATION`，並修復這個問題。

## 時間限制

40 分鐘
