# Q009 解答：LocalSocketImpl 超時設置使用錯誤常量

## 問題根因

在 `LocalSocketImpl.java` 的 `setOption()` 方法中，
設置超時時使用了錯誤的 socket 選項常量。

## Bug 位置

**文件**: `frameworks/base/core/java/android/net/LocalSocketImpl.java`

**問題代碼**:

```java
public void setOption(int optID, Object value) throws IOException {
    // ...
    switch (optID) {
        // ...
        case SocketOptions.SO_TIMEOUT:
            StructTimeval timeval = StructTimeval.fromMillis(intValue);
            Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, 
                    OsConstants.SO_SNDTIMEO, timeval);  // Bug: 只設了發送超時
            Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, 
                    OsConstants.SO_SNDTIMEO, timeval);  // Bug: 重複設發送超時
            break;
        // ...
    }
}
```

## 修復方案

正確設置接收和發送超時：

```java
case SocketOptions.SO_TIMEOUT:
    StructTimeval timeval = StructTimeval.fromMillis(intValue);
    Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, 
            OsConstants.SO_RCVTIMEO, timeval);  // ← 接收超時
    Os.setsockoptTimeval(fd, OsConstants.SOL_SOCKET, 
            OsConstants.SO_SNDTIMEO, timeval);  // ← 發送超時
    break;
```

## 驗證步驟

1. 應用修復 patch
2. 編譯 framework
3. 重新運行測試：
   ```bash
   atest android.net.cts.LocalSocketTest#testSetSoTimeout_readTimeout
   ```

## 學習要點

- `SO_TIMEOUT` 需要同時設置 `SO_RCVTIMEO` 和 `SO_SNDTIMEO`
- 複製貼上時要確保修改所有需要改變的部分
- 讀取超時由 `SO_RCVTIMEO` 控制
