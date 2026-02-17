# Q010: ParcelFileDescriptor 跨進程文件操作三層模式錯誤

## 問題描述

CTS 測試 `testParcelFileDescriptor` 失敗，跨進程傳遞的文件描述符操作模式與預期不符，導致讀寫操作失敗。

## 失敗的 CTS 測試

```
Module: CtsOsTestCases
Test: android.os.cts.ParcelFileDescriptorTest#testParcelFileDescriptor
```

## 錯誤訊息

```
junit.framework.AssertionFailedError: ParcelFileDescriptor mode mismatch
Expected: MODE_READ_WRITE allows both read and write
Actual: IOException - Bad file descriptor on write operation
Also: mode parsing returns wrong flags, Parcel transmission corrupts mode
    at android.os.cts.ParcelFileDescriptorTest.testParcelFileDescriptor
```

## 相關日誌

```
D ParcelFileDescriptor: open: requested mode=0x30000000 (READ_WRITE)
D ParcelFileDescriptor: parseMode: mode string "rw" parsed as 0x10000000 (READ_ONLY!)
D ParcelFileDescriptor: writeToParcel: writing mode with wrong byte order
D ParcelFileDescriptor: constructor(Parcel): reading mode, got 0x00000010 (truncated!)
D ContentProvider: openFile: returning PFD with corrupted mode
```

## 提示

1. 檢查 parseMode() 的字符串解析邏輯
2. 追蹤 writeToParcel/constructor(Parcel) 的序列化順序
3. 驗證 ContentProvider 的模式傳遞
4. **三層都有模式處理的問題**

## 影響範圍

- 跨進程的文件描述符傳遞
- ContentProvider 的文件共享
- SAF (Storage Access Framework) 操作

## 難度評估

- **時間:** 50 分鐘
- **複雜度:** 高（文件描述符模式的多層處理錯誤）
