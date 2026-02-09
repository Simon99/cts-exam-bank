# Q004 答案：ProxyFileDescriptor 讀取返回長度與回調錯誤

## Bug 位置

### Bug 1: FuseAppLoop.java
**檔案路徑:** `frameworks/base/core/java/com/android/internal/os/FuseAppLoop.java`
**行號:** 約 188 行
**問題:** `replyRead()` 使用請求的 `size` 而非實際讀取的 `readSize`

### Bug 2: ProxyFileDescriptorCallback.java
**檔案路徑:** `frameworks/base/core/java/android/os/ProxyFileDescriptorCallback.java`
**行號:** 約 61 行
**問題:** 默認實現返回 0 而非拋出 `ErrnoException`

## 修復方法

### 修復 Bug 1:
```java
// 錯誤代碼
replyRead(uniqueId, size, data);

// 正確代碼
replyRead(uniqueId, readSize, data);
```

### 修復 Bug 2:
```java
// 錯誤代碼
public int onRead(long offset, int size, byte[] data) throws ErrnoException {
    return 0;
}

// 正確代碼
public int onRead(long offset, int size, byte[] data) throws ErrnoException {
    throw new ErrnoException("onRead", OsConstants.EBADF);
}
```

## 根本原因分析

這是一個**返回值處理 + 默認行為**雙重錯誤：

1. FuseAppLoop 忽略了回調的實際讀取長度
2. 回調的默認實現返回 0（表示 EOF）而非報錯

測試場景：
- 請求讀取 4096 bytes
- 回調實際只讀取 1024 bytes
- FuseAppLoop 錯誤地回報讀取了 4096 bytes

## 調試思路

1. CTS 測試創建 ProxyFileDescriptor 並讀取數據
2. 讀取返回的長度與實際不符
3. 追蹤 `onRead()` 的返回值處理
4. 發現 `replyRead()` 使用了錯誤的參數
5. 檢查默認回調行為，發現也有問題
