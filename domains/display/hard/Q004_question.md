# CTS 題目：Display Mode 支援清單不完整

## 🎯 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay
```

**模組**: `CtsDisplayTestCases`

## 📋 測試失敗訊息

```
junit.framework.AssertionFailedError: Could not find alternative display mode 
with refresh rate 90.0 for Mode{mPhysicalWidth=1080, mPhysicalHeight=2400, 
mRefreshRate=60.0, mAlternativeRefreshRates=[90.0, 120.0]}. 
All supported modes are [Mode{id=1, w=1080, h=2400, fps=60.0, ...}, 
Mode{id=2, w=1080, h=2400, fps=90.0, ...}]
    at android.display.cts.DisplayTest.testGetSupportedModesOnDefaultDisplay(DisplayTest.java:889)
```

## 🔍 問題描述

在支援多重新率模式的設備上（如 60Hz/90Hz/120Hz），CTS 測試 `testGetSupportedModesOnDefaultDisplay` 間歇性失敗。測試驗證 `getSupportedModes()` 返回的所有顯示模式，確保每個模式的 `alternativeRefreshRates` 中列出的刷新率都有對應的模式存在。

**奇怪的現象**：
- 在只支援單一刷新率的設備上測試通過
- 在支援 2 個或更多刷新率的設備上，有時會失敗
- 錯誤訊息顯示某個 alternative rate 找不到對應的模式
- 用 `adb shell dumpsys display` 檢查時，設備確實支援該刷新率

## 📁 相關源碼檔案

請檢查以下檔案：
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`

重點關注 `updateLocked()` 方法中 `supportedModes` 的處理邏輯（約 470 行附近）。

## 💡 提示

1. CTS 測試使用 Union-Find 演算法驗證 mode 之間的對稱性
2. 測試假設如果 Mode A 的 alternativeRefreshRates 包含 Rate X，那麼一定存在一個 Mode B 的 refreshRate 等於 Rate X
3. 注意陣列複製時的邊界計算
4. 思考：什麼情況下會導致「modes 數量」與預期不符？

## ⏱️ 建議時間

35 分鐘

## 📝 作答要求

1. 找出 bug 的精確位置（檔案名稱與行號）
2. 解釋 bug 的成因與觸發條件
3. 說明為什麼這個 bug 會導致 CTS 測試失敗
4. 提供修復方案
