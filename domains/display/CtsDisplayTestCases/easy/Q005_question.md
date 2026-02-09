# CTS 測試失敗 — Framebuffer 尺寸限制異常

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testRestrictedFramebufferSize`

## CTS 失敗 Log
```
junit.framework.ComparisonFailure: expected:<[]> but was:<[1920]>
  at org.junit.Assert.assertEquals(Assert.java:115)
  at org.junit.Assert.assertEquals(Assert.java:144)
  at android.display.cts.DisplayTest.testRestrictedFramebufferSize(DisplayTest.java:...)
```

## 提示
此題涉及系統屬性配置。除了 frameworks 層源碼，也需要檢查設備專屬配置（如 `device/google/panther/` 下的屬性檔案）。

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
