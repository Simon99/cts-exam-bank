# CTS 測試失敗 — AudioFormat PCM Encoding 不一致

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.AudioEncoderTest#testEncodeFloat`

## CTS 失敗 Log
```
junit.framework.AssertionError: PCM encoding mismatch
Configured encoder with: ENCODING_PCM_FLOAT (4)
But MediaFormat reports: ENCODING_PCM_16BIT (2)
  at org.junit.Assert.fail(Assert.java:87)
  at org.junit.Assert.assertEquals(Assert.java:118)
  at android.mediav2.cts.AudioEncoderTest.testEncodeFloat(AudioEncoderTest.java:234)
```

## 額外資訊
- 測試配置 float PCM 輸入進行編碼
- 但 output format 顯示 16-bit PCM

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過
