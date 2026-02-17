# Q008 解答：LocalSocket 輸出流寫入後數據截斷

## 問題根因

`LocalSocketImpl.SocketOutputStream.write()` 方法調用 native 方法時，將 `len` 錯誤地減去 1。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼** (SocketOutputStream.write 方法):

```java
public void write(byte[] b, int off, int len) throws IOException {
    synchronized (writeMonitor) {
        FileDescriptor myFd = fd;
        if (myFd == null) throw new IOException("socket closed");
        
        if (off < 0 || len < 0 || (off + len) > b.length) {
            throw new ArrayIndexOutOfBoundsException();
        }
        writeba_native(b, off, len - 1, myFd);  // Bug: len - 1
    }
}
```

## 修復方案

```java
public void write(byte[] b, int off, int len) throws IOException {
    synchronized (writeMonitor) {
        FileDescriptor myFd = fd;
        if (myFd == null) throw new IOException("socket closed");
        
        if (off < 0 || len < 0 || (off + len) > b.length) {
            throw new ArrayIndexOutOfBoundsException();
        }
        writeba_native(b, off, len, myFd);  // 正確：傳遞完整的 len
    }
}
```

## 問題分析

`len` 參數的語義是「要寫入的字節數」，不是「最後一個索引」。

| 語義 | 計算方式 |
|-----|---------|
| 長度 (length) | 直接使用 |
| 最後索引 (lastIndex) | length - 1 |

錯誤地將 length 當作 lastIndex 處理，導致少寫 1 字節。

## 呼叫鏈

```
OutputStream.write(data, 0, 65536)
    └── synchronized(writeMonitor)
    └── 邊界檢查通過
    └── writeba_native(data, 0, 65535, fd)  // Bug: 少寫 1 字節
            └── write() syscall 寫入 65535 字節

接收端：
    └── 只收到 65535 字節，少 1 字節
```

## 驗證命令

```bash
atest android.net.cts.LocalSocketTest#testLargeDataTransfer
```

## 學習要點

- 區分「長度」和「索引」的語義
- off-by-one 錯誤是常見的 bug 類型
- 傳遞給 native 方法的參數需要仔細核對
- 大數據測試可以暴露這類邊界問題
