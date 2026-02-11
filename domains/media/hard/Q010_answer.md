# Media-H-Q030 解答

## Root Cause
問題出在三個檔案的加密 sample 資訊處理：

1. `NuMediaExtractor.cpp` - 組裝 CryptoInfo 時陣列處理錯誤：
```cpp
// Bug: 當有 numPageSamples 附加資料時，只擴展 plainSizes
// 但忘記同步擴展 encryptedSizes
if (mbuf->meta_data().findData(kKeyEncryptedSizes, &type, &data, &size)) {
    // 擴展 plainSizes (正確)
    // 但 encryptedSizes 少 append 一個 0 (BUG)
}
```

2. `DrmHal.cpp` - CryptoInfo 驗證不嚴格：
```cpp
// Bug: 沒有驗證 plainSizes 和 encryptedSizes 長度一致
// 就直接傳遞給 Java 層
```

3. `MediaExtractor.java` - getSampleCryptoInfo 錯誤處理：
```java
// Bug: native 返回的陣列長度不一致時沒有正確處理
// 直接使用錯誤的資料
```

## Subsample Encryption 結構

CENC 格式中，一個 sample 可以有多個 subsample：
```
[clear1][encrypted1][clear2][encrypted2]...

numSubSamples = 4
numBytesOfClearData    = [16, 0, 0, 0]
numBytesOfEncryptedData = [1024, 512, 256, 0]  // 最後一個是 0

當加入 Vorbis numPageSamples 時：
numSubSamples = 5
numBytesOfClearData    = [16, 0, 0, 0, 4]     // 多加一個明文區塊
numBytesOfEncryptedData = [1024, 512, 256, 0, 0]  // 也要多加一個 0！
```

## 涉及檔案
- `frameworks/av/media/libstagefright/NuMediaExtractor.cpp`
- `frameworks/av/drm/libmediadrm/DrmHal.cpp`
- `frameworks/base/media/java/android/media/MediaExtractor.java`

## Bug Pattern
Pattern C（縱深多層）- 影響 3 個檔案，加密資訊從 native 到 Java 的傳遞

## 追蹤路徑
1. CTS log → encryptedSizes 陣列長度錯誤
2. 檢查 Java MediaExtractor → getSampleCryptoInfo 的 native 實現
3. 追蹤 NuMediaExtractor → 發現 numPageSamples 處理邏輯
4. 追蹤 kKeyPlainSizes/kKeyEncryptedSizes → 發現只更新了 plainSizes
5. 確認 DrmHal 沒有驗證邏輯

## 修復要點

```cpp
// NuMediaExtractor.cpp 正確邏輯
// 當 append numPageSamples 時，兩個陣列都要擴展：

// 1. 擴展 plainSizes
memcpy(adata + size, &int32Size, sizeof(int32Size));
mbuf->meta_data().setData(kKeyPlainSizes, type, adata, newSize);

// 2. 也要擴展 encryptedSizes (加入一個 0)
int32_t zero = 0;
memcpy(encData + size, &zero, sizeof(zero));
mbuf->meta_data().setData(kKeyEncryptedSizes, type, encData, newSize);
```

## 評分標準
| 項目 | 權重 | 說明 |
|------|------|------|
| 理解 CENC subsample 結構 | 20% | 知道 clear/encrypted 配對 |
| 正確定位所有相關檔案 | 25% | 找到全部 3 個檔案 |
| 理解 numPageSamples 影響 | 25% | 知道 Vorbis 特殊處理 |
| 修復方案正確 | 20% | 同步擴展兩個陣列 |
| 考慮邊界情況 | 10% | 非 Vorbis track 的處理 |

## 常見錯誤方向
- 只看 Java 層不追蹤 Native
- 不理解 kKeyPlainSizes/kKeyEncryptedSizes 的用途
- 忽略 Vorbis track 的特殊處理
- 認為問題在 DRM 解密而非 metadata 組裝
