# Q006: FAT UUID 轉換格式錯誤

## 問題描述

CTS 測試 `testFatUuidHandling` 失敗，FAT 檔案系統的 UUID 轉換結果與預期不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testFatUuidHandling
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: UUID mismatch
Expected: fafafafa-fafa-5afa-8afa-fafaabcd1234
Actual: fafafafa-fafa-5afa-8afa-fafaABCD
    at android.os.storage.cts.StorageManagerTest.testFatUuidHandling
```

## 相關日誌

```
D StorageManager: convert: fsUuid=ABCD-1234
D StorageManager: hex conversion: ABCD (should be abcd1234)
D StorageManager: Generated UUID: fafafafa-fafa-5afa-8afa-fafaABCD
D DiskInfo: getNormalizedFatUuid: ABCD1234 (uppercase, no hyphen)
```

## 提示

1. 檢查字串大小寫轉換
2. 驗證子字串截取邏輯
3. 確認格式化的一致性

## 影響範圍

- USB 隨身碟識別
- SD 卡掛載功能

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解 UUID 格式規範）
