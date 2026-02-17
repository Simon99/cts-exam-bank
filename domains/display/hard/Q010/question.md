# CTS 題目：User Disabled HDR Types 設定未被儲存

## 背景

某設備廠商報告了一個問題：使用者透過 `DisplayManager.setUserDisabledHdrTypes()` 設定禁用的 HDR 類型後，重新啟動應用程式或設備後，設定消失了。

使用者明確禁用了 Dolby Vision 和 HLG 類型，但系統沒有正確持久化這些設定到 Settings.Global。

## 失敗的 CTS 測試

```
android.display.cts.DisplayTest#testSetUserDisabledHdrTypesStoresDisabledFormatsInSettings
```

**測試模組**: `CtsDisplayTestCases`

## 症狀

1. 調用 `setUserDisabledHdrTypes()` 時沒有錯誤
2. 但 `Settings.Global.USER_DISABLED_HDR_FORMATS` 沒有被更新
3. 禁用的 HDR 類型設定無法持久化
4. 設備重啟後，所有 HDR 類型又會被啟用

## 相關檔案

- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`

## 任務

1. 找出導致 HDR 類型設定未被儲存的 bug
2. 解釋為什麼設定沒有被持久化
3. 分析這個 bug 對使用者體驗的影響
4. 提供修復方案

## 提示

- 關注 `setUserDisabledHdrTypesInternal()` 方法的邏輯流程
- 檢查是否有提前返回（early return）導致後續代碼沒有執行
- 追蹤 `Settings.Global.putString()` 是否被正確調用

## 評估標準

| 項目 | 配分 |
|------|------|
| 準確定位 bug 位置 | 25% |
| 正確解釋 bug 原因 | 25% |
| 分析對使用者的影響 | 25% |
| 提供有效修復方案 | 25% |

## 時間限制

35 分鐘
