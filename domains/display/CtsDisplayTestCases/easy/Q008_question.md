# CTS 測試失敗 — Display 刷新率獲取異常

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsDisplayTestCases`
- Test: `android.display.cts.DisplayTest#testMode`

## CTS 失敗 Log
```
junit.framework.AssertionError: expected:<60.0> but was:<0.0>
  at org.junit.Assert.assertEquals(Assert.java:...)
  at android.display.cts.DisplayTest.testMode(DisplayTest.java:...)
```

## 補充信息
測試驗證 `Display.getRefreshRate()` 返回值應該與 `Mode.getRefreshRate()` 一致，但實際返回 0.0。

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
