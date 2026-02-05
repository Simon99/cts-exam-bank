# CTS 測試失敗 — 亮度配置權限檢查異常

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.BrightnessTest#testConfigureBrightnessPermission`

## CTS 失敗 Log
```
java.lang.AssertionError
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.fail(Assert.java:96)
  at android.display.cts.BrightnessTest.testConfigureBrightnessPermission(BrightnessTest.java:325)
```

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
