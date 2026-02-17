# Q004: ProxyFileDescriptor 讀取返回錯誤長度

## 問題描述

CTS 測試 `testOpenProxyFileDescriptor_largeRead` 失敗，讀取操作返回的長度與實際不符。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.storage.cts.StorageManagerTest#testOpenProxyFileDescriptor_largeRead
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: Expected read size 1024 but got 4096
    at android.os.storage.cts.StorageManagerTest.testOpenProxyFileDescriptor_largeRead
```

## 相關日誌

```
D FuseAppLoop: handleRead: inode=1 offset=0 size=4096
D FuseAppLoop: Callback returned readSize=1024
D FuseAppLoop: replyRead: reporting size=4096 (should be 1024)
W StorageManagerTest: Read size mismatch: expected 1024, got 4096
```

## 提示

1. 追蹤 `onRead()` 回調的返回值
2. 檢查 `replyRead()` 使用的參數
3. 驗證默認回調的行為

## 影響範圍

- 自定義 FUSE 檔案系統
- 虛擬檔案提供者

## 難度評估

- **時間:** 25 分鐘
- **複雜度:** 中等（需要理解 FUSE 讀取流程）
