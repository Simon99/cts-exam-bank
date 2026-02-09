# CTS 測試失敗 — MediaCodecInfo Profile Level 驗證錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.CodecInfoTest#testProfileLevelSupport`

## CTS 失敗 Log
```
junit.framework.AssertionError: ProfileLevel array is corrupted
Expected profile-level pairs: [(1,1), (1,2), (2,1), (2,2)]
Actual: ArrayIndexOutOfBoundsException when accessing profileLevels[2]
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.CodecInfoTest.testProfileLevelSupport(CodecInfoTest.java:423)
Caused by: java.lang.ArrayIndexOutOfBoundsException: Index 2 out of bounds for length 2
  at android.media.MediaCodecInfo$CodecCapabilities.getProfileLevels(MediaCodecInfo.java:1567)
```

## 額外資訊
- Codec 應該支援 4 組 profile-level 組合
- `getProfileLevels()` 只返回 2 個元素
- 存取第 3 個元素時拋出 ArrayIndexOutOfBoundsException

## 任務
1. 定位造成此測試失敗的原始碼修改
2. 說明 root cause
3. 提出修復方案並驗證 CTS 通過

## 提示
追蹤 profileLevels array 從 native 傳到 Java 的過程。
