# CTS 考題：Virtual Display 釋放時的空指標處理缺陷

## 題目編號
DIS-M006

## 難度
Medium

## 情境描述

你的團隊收到一個客戶回報：在特定情況下，嘗試釋放一個已經不存在的虛擬顯示器時，系統會發生異常崩潰。

錯誤日誌顯示：
```
E AndroidRuntime: FATAL EXCEPTION: android.display
E AndroidRuntime: Process: system_server, PID: 1234
E AndroidRuntime: java.lang.NullPointerException: Attempt to invoke virtual method 
    'android.view.DisplayAddress android.hardware.display.DisplayDevice.getDisplayDeviceInfoLocked()
    .address' on a null object reference
E AndroidRuntime:     at com.android.server.display.DisplayDeviceRepository.onDisplayDeviceEvent
E AndroidRuntime:     at com.android.server.display.DisplayManagerService.releaseVirtualDisplayInternal
```

## 相關 CTS 測試

當此 bug 存在時，以下測試會失敗：

```
android.hardware.display.cts.VirtualDisplayTest#testPrivateVirtualDisplay
```

測試模組：`CtsDisplayTestCases`

## 任務

請檢查以下檔案中的 `releaseVirtualDisplayInternal()` 方法，找出可能導致此問題的程式碼缺陷：

**檔案路徑**：
```
frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java
```

## 問題

1. **找出 Bug**：`releaseVirtualDisplayInternal()` 方法中存在什麼缺陷？

2. **分析影響**：
   - 這個 bug 在什麼情況下會被觸發？
   - 為什麼會導致 NullPointerException？

3. **修復方案**：請提供修復此問題的程式碼補丁。

## 提示

- 仔細閱讀 `releaseVirtualDisplayLocked()` 的返回值語義
- 考慮當虛擬顯示器已經被釋放或從未存在時的情況
- 空值檢查是防禦性程式設計的重要實踐

## 時間限制

建議 25 分鐘內完成

## 評分標準

- 正確識別 bug 位置（30%）
- 完整分析觸發條件和影響（30%）
- 提供正確且完整的修復方案（40%）
