# DIS-E009: HdrCapabilities 返回值錯誤

## 問題描述

裝置的 CTS 測試 `DisplayTest#testDefaultDisplayHdrCapability` 失敗，錯誤訊息顯示 HDR luminance 值不符合預期的大小關係。

## 失敗的測試

- **模組**: CtsDisplayTestCases
- **測試**: android.display.cts.DisplayTest#testDefaultDisplayHdrCapability

## 錯誤訊息

```
assertTrue(cap.getDesiredMinLuminance() <= cap.getDesiredMaxAverageLuminance())
Expected: true
Actual: false
```

## 背景知識

HDR（High Dynamic Range）顯示需要正確報告其亮度範圍：
- `minLuminance`: 最小亮度（暗場）
- `maxAverageLuminance`: 平均最大亮度
- `maxLuminance`: 峰值最大亮度

這些值必須滿足：`min <= average <= max`

## 任務

找出導致 minLuminance 值異常的程式碼錯誤並修復。

## 提示

- 檢查 `HdrCapabilities` 類的 getter 方法
- 查看 `frameworks/base/core/java/android/view/Display.java`
