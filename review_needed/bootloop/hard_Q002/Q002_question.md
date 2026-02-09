# CTS Hard Q002: Display Mode API 層數據不一致

## 問題描述

你的團隊收到了一個 bug 報告：在支援多種顯示模式的設備上，CTS 測試 `DisplayTest#testGetSupportedModesOnDefaultDisplay` 會失敗。

測試輸出顯示：
```
org.junit.AssertionError: Could not find alternative display mode with refresh rate 
90.0 for Mode{modeId=1, resolution=1080x2400, refreshRate=60.0, ...}. 
All supported modes are [{id=1, width=1080, height=2400, fps=60.0, ...}]
```

## 症狀

1. `testGetSupportedModesOnDefaultDisplay` 測試失敗
2. 錯誤訊息顯示 alternative refresh rates 找不到對應的 mode
3. **設備正常運作，系統穩定** - 只有 CTS 測試會失敗
4. 問題在支援 2 種以上顯示模式的設備上重現

## 奇怪的現象

- 通過 adb 查看系統日誌，顯示內部 supportedModes 數量正確
- 但應用程式 dump 出的 modes 數量比預期少 1 個
- 系統服務正常運作，mode 切換功能正常

## 相關代碼區域

這個功能涉及以下數據傳遞鏈：
1. **DisplayDeviceInfo** - 物理顯示設備的原始資訊
2. **DisplayInfo** - 系統內部使用的顯示資訊
3. **Display** - 暴露給應用程式的 API 層

數據流向：
```
DisplayDeviceInfo.supportedModes 
    → LogicalDisplay.updateLocked() 
    → DisplayInfo.supportedModes 
    → Display.getSupportedModes()
```

## 你的任務

1. 找出為什麼應用看到的 modes 數量比系統內部少
2. 確定 bug 位於哪個檔案的哪個方法
3. 解釋為什麼這個 bug 不會導致系統崩潰，但會導致 CTS 失敗

## 提示

- Bug 不在數據傳遞的源頭，而是在數據暴露給應用的最後一步
- 思考防禦性複製（defensive copy）可能出現的問題
- 為什麼系統內部正常，但 API 返回不正確？

## 涉及檔案

- `frameworks/base/services/core/java/com/android/server/display/DisplayDeviceInfo.java`
- `frameworks/base/core/java/android/view/DisplayInfo.java`
- `frameworks/base/core/java/android/view/Display.java`
