# CTS 面試題 - Display Hard Q005

## 題目類型
**Hard - 多檔案交互 Bug（3+ 檔案）**

## 背景
你正在調試一個 Android 14 設備上的 Display 相關問題。用戶報告在設置中禁用某些 HDR 格式後，應用程式仍然可以看到這些被禁用的 HDR 類型。

## 問題描述
用戶在 Settings > Display 中禁用了 Dolby Vision 和 HLG 格式，並且將 `areUserDisabledHdrTypesAllowed` 設置為 `false`（表示應用不應該看到被禁用的格式）。

然而，當應用調用 `Display.getHdrCapabilities().getSupportedHdrTypes()` 時，仍然返回包含 Dolby Vision 和 HLG 的完整 HDR 類型列表，而不是預期的過濾後列表。

## 失敗的 CTS 測試
```
android.display.cts.DisplayTest#testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes
```

## 測試失敗日誌
```
junit.framework.AssertionFailedError: arrays first differed at element [0]; 
expected:<[2, 4]> but was:<[1, 2, 3, 4]>
    at android.display.cts.DisplayTest.testGetHdrCapabilitiesWhenUserDisabledFormatsAreNotAllowedReturnsFilteredHdrTypes

HDR Type Constants:
  HDR_TYPE_DOLBY_VISION = 1
  HDR_TYPE_HDR10 = 2
  HDR_TYPE_HLG = 3
  HDR_TYPE_HDR10_PLUS = 4
```

## 架構說明
HDR 禁用類型的數據流：
```
DisplayManager.setUserDisabledHdrTypes()
    ↓
DisplayManagerService.setUserDisabledHdrTypesInternal()
    ↓
DisplayManagerService.setAreUserDisabledHdrTypesAllowedInternal()
    ↓
LogicalDisplay.setUserDisabledHdrTypes()
    ↓
DisplayInfo.userDisabledHdrTypes
    ↓
Display.getHdrCapabilities() [過濾邏輯]
```

## 你的任務
1. 分析 HDR 類型禁用功能的跨檔案交互流程
2. 找出導致 `userDisabledHdrTypes` 不能正確傳遞的 bug
3. 這個 bug 涉及至少 3 個檔案之間的交互
4. 提供修復方案

## 相關源代碼路徑
- `frameworks/base/services/core/java/com/android/server/display/DisplayManagerService.java`
- `frameworks/base/services/core/java/com/android/server/display/LogicalDisplay.java`
- `frameworks/base/core/java/android/view/Display.java`

## 調試提示
- 追蹤 `setUserDisabledHdrTypes()` 從 DisplayManagerService 到最終 API 的完整調用鏈
- 注意 lambda 中變量捕獲的問題
- 注意數組比較的方式（引用比較 vs 內容比較）
- 思考 DisplayInfo 的緩存機制（mInfo）是如何觸發更新的
