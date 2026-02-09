# CTS 測試失敗 — Decoder Color Aspects 處理錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.DecoderColorAspectsTest#testColorSpace`

## CTS 失敗 Log
```
junit.framework.AssertionError: Color space mismatch after decode
Expected color primaries: BT709 (1)
Actual color primaries: BT2020 (9)
Expected transfer: SRGB (2)
Actual transfer: ST2084 (16)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.DecoderColorAspectsTest.testColorSpace(DecoderColorAspectsTest.java:267)

Input: SDR BT.709 content
Output: Incorrectly marked as HDR BT.2020
```

## 額外資訊
- 測試解碼 BT.709 SDR 內容
- Output format 顯示錯誤的 color aspects
- Color primaries, transfer, matrix 三個值都錯
- 導致顯示顏色異常

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 color aspects 從 bitstream 解析到 output format 的過程。
