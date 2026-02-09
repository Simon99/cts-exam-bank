# CTS 測試失敗 — MediaCodecList 過濾邏輯錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecListTest#testGetCodecInfos`

## CTS 失敗 Log
```
junit.framework.AssertionError: REGULAR_CODECS should not include software-only codecs
Expected: codec count with REGULAR_CODECS < codec count with ALL_CODECS
Actual: counts are equal (both 45)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertTrue(Assert.java:42)
  at android.mediav2.cts.CodecListTest.testGetCodecInfos(CodecListTest.java:156)
```

## 額外資訊
- `MediaCodecList(REGULAR_CODECS)` 應該過濾掉 software-only codecs
- `MediaCodecList(ALL_CODECS)` 應該包含所有 codecs
- 目前兩者返回相同數量的 codecs

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
需要追蹤 MediaCodecList 的建構過程及 filter 邏輯。
