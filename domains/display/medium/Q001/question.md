# DIS-M001: Display Mode Alternative Refresh Rates 異常

## 題目描述

團隊收到 bug report：在某些多刷新率顯示器上，CTS 測試 `DisplayTest#testGetSupportedModesOnDefaultDisplay` 偶發失敗。

失敗的 CTS Log 顯示：
```
FAILURE: Expected {width=1080, height=2400, fps=120.0} to be listed as 
alternative refresh rate of {width=1080, height=2400, fps=60.0}. 
All supported modes are [...]
```

測試驗證的是 `Display.Mode.getAlternativeRefreshRates()` 回報的替代刷新率列表應該具備對稱性：如果 Mode A 的替代刷新率包含 Mode B 的頻率，那麼 Mode B 的替代刷新率也應該包含 Mode A 的頻率。

問題在設備啟動後第一次查詢時最容易重現，後續查詢通常正常。

## 測試環境

- CTS Module: `CtsDisplayTestCases`
- 測試方法: `android.display.cts.DisplayTest#testGetSupportedModesOnDefaultDisplay`
- 相關檔案: `frameworks/base/services/core/java/com/android/server/display/LocalDisplayAdapter.java`

## 任務

1. 分析 `LocalDisplayAdapter.java` 中建構 alternative refresh rates 的邏輯
2. 找出導致對稱性被破壞的 bug
3. 解釋為什麼這個 bug 在第一次查詢時更容易重現
4. 提供修復方案

## 提示

- 重點關注 `updateDisplayModesLocked()` 或類似方法中遍歷 displayModes 的迴圈
- 思考邊界條件：陣列的第一個和最後一個元素是否都被正確處理？
- 注意 for 迴圈的終止條件

## 預計時間

25 分鐘
