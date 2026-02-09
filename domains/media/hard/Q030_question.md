# CTS 測試失敗 — MediaExtractor 加密 Track Sample 處理錯誤

## 環境
- 裝置：Pixel 7 (Panther)
- Android：AOSP 14 (AP2A.240905.003)
- 源碼：~/aosp-panther/

## 失敗測試
- Module: `CtsMediaV2TestCases`
- Test: `android.mediav2.cts.ExtractorTest#testEncryptedTrackExtraction`

## CTS 失敗 Log
```
junit.framework.AssertionError: CryptoInfo validation failed
getSampleCryptoInfo returned invalid subsample data:
  numSubSamples: 4
  numBytesOfClearData: [16, 0, 0, 0]  (expected length=4)
  numBytesOfEncryptedData: [1024, 512, 256]  (length=3, MISMATCH!)
  
Arrays must have same length as numSubSamples.
Expected: 4 elements each
Actual: plainSizes=4, encryptedSizes=3

Sample details:
  Track: video/avc (encrypted)
  Sample size: 1808 bytes
  Encryption scheme: cenc (AES-CTR)
  
  at org.junit.Assert.fail(Assert.java:87)
  at android.mediav2.cts.ExtractorTest.validateCryptoInfo(ExtractorTest.java:623)
  at android.mediav2.cts.ExtractorTest.testEncryptedTrackExtraction(ExtractorTest.java:678)
```

## 額外資訊
- 測試使用 CENC (Common Encryption) 加密的 MP4 檔案
- CryptoInfo 包含 subsample 資訊：哪些是明文、哪些是密文
- numBytesOfClearData 和 numBytesOfEncryptedData 陣列長度必須相同
- 實際上密文陣列少了一個元素

## CryptoInfo 背景
```java
class CryptoInfo {
    int numSubSamples;           // subsample 數量
    int[] numBytesOfClearData;   // 每個 subsample 的明文長度
    int[] numBytesOfEncryptedData; // 每個 subsample 的密文長度
    byte[] key;                  // 解密金鑰
    byte[] iv;                   // 初始化向量
}
```

## 任務
1. 定位造成 CryptoInfo 陣列長度不一致的原始碼修改
2. 說明 subsample encryption 的資料結構
3. 提出修復方案並驗證 CTS 通過

## 提示
需要追蹤 NuMediaExtractor → DrmHal → Java MediaExtractor 的加密資訊傳遞流程。
